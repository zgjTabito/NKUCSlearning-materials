document.addEventListener("DOMContentLoaded", function () {
    // 图表尺寸配置
    const width = 640;
    const height = 400;
    const margin = { top: 20, right: 30, bottom: 30, left: 40 };
    const colorScheme = ["#218838", "#0056b3", "#ff6347", "#d62728", "#9467bd"]; // 更换醒目颜色

    const svg = d3.select("#line_chart")
        .attr("width", width)
        .attr("height", height);

    // 加载数据
    d3.csv("WorldHappiness_Corruption_2015_2020.csv").then(data => {
        // 格式化数据
        data.forEach(d => {
            d.happiness = +d.happiness_score;
            d.year = +d.Year;
        });

        // 提取国家列表并去重
        const countries = Array.from(new Set(data.map(d => d.Country))).sort();

        // 计算 y 轴的最大值和最小值
        const yMax = d3.max(data, d => d.happiness);

        // 设置 x 和 y 轴比例尺
        const x = d3.scaleBand() // 使用 d3.scaleBand 来确保每个年份都显示
            .domain([2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024, 2025, 2026]) // x 轴的域是所有年份
            .range([margin.left, width - margin.right])
            .padding(0.1); // 设置条形之间的间隔

        const y = d3.scaleLinear()
            .domain([0, yMax]) // 设置 y 轴的域为数据的最小值和最大值
            .range([height - margin.bottom, margin.top]);

        // 绘制轴的函数
        function drawAxes() {
            // 添加 x 轴
            svg.append("g")
                .attr("class", "x-axis")
                .attr("transform", `translate(0,${height - margin.bottom})`)
                .call(d3.axisBottom(x).tickFormat(d3.format("d"))); // 格式化为年份

            // 添加 y 轴
            svg.append("g")
                .attr("class", "y-axis")
                .attr("transform", `translate(${margin.left},0)`)
                .call(d3.axisLeft(y));
        }

        // 初始绘制轴
        drawAxes();

        // 存储选中的国家
        let selectedCountries = [];

        function updateChart(data, selectedCountries) {
            // 清除之前的折线、数据点、国家标签和图例
            svg.selectAll(".line-path").remove();
            svg.selectAll(".data-point").remove();
            svg.selectAll(".country-label1").remove();
            svg.selectAll(".legend-line").remove();  // 清除图例线
            svg.selectAll(".legend-dot").remove();   // 清除图例圆点

            // 绘制所有国家的灰色线条
            countries.forEach(country => {
                const countryData = data.filter(d => d.Country === country && d.year >= 2015);
                const line = d3.line()
                    .defined(d => d.happiness !== null)
                    .x(d => x(d.year) + x.bandwidth() / 2)
                    .y(d => y(d.happiness));

                svg.append("path")
                    .datum(countryData)
                    .attr("class", "line-path")
                    .attr("fill", "none")
                    .attr("stroke", "#d3d3d3") // 设置为浅灰色
                    .attr("stroke-width", 1.5)
                    .attr("d", line);
            });

            // 高亮显示选中的国家
            selectedCountries.forEach((country, index) => {
                const filteredData = data.filter(d => d.Country === country && d.year >= 2015);

                const line = d3.line()
                    .defined(d => d.happiness !== null)
                    .x(d => x(d.year) + x.bandwidth() / 2)
                    .y(d => y(d.happiness));

                // 绘制实线部分
                const solidData = filteredData.filter(d => d.year <= 2023);
                const dashedData = filteredData.filter(d => d.year >= 2015);

                // 绘制实线部分
                const solidPath = svg.append("path")
                    .datum(solidData)
                    .attr("class", "line-path")
                    .attr("fill", "none")
                    .attr("stroke", colorScheme[index])
                    .attr("stroke-width", 3)
                    .attr("d", line);

                // 添加路径动画（实线部分）
                const solidPathLength = solidPath.node().getTotalLength();
                solidPath
                    .attr("stroke-dasharray", solidPathLength) // 设置路径总长度
                    .attr("stroke-dashoffset", solidPathLength) // 初始隐藏路径
                    .transition()
                    .duration(2000) // 动画时长
                    .ease(d3.easeLinear) // 动画效果
                    .attr("stroke-dashoffset", 0); // 完全显示路径

                // 绘制虚线部分
                const dashedPath = svg.append("path")
                    .datum(dashedData)
                    .attr("class", "line-path dashed")
                    .attr("fill", "none")
                    .attr("stroke", colorScheme[index])
                    .attr("stroke-width", 3)
                    .attr("stroke-dasharray", "5,5") // 设置虚线样式
                    .attr("d", line);

                // 添加路径动画（虚线部分）
                const dashedPathLength = dashedPath.node().getTotalLength();
                dashedPath
                    .attr("stroke-dasharray", "5,5") // 保持虚线样式
                    .attr("stroke-dashoffset", dashedPathLength * 10) // 初始隐藏路径 (虚线间隔比例放大)
                    .transition()
                    .delay(2000) // 延迟虚线的动画，确保实线完成后开始
                    .duration(2000) // 动画时长
                    .ease(d3.easeLinear) // 动画效果
                    .attr("stroke-dashoffset", 0); // 完全显示路径

                // 添加数据点
                svg.selectAll(`.data-point-${index}`)
                    .data(filteredData.filter(d => !isNaN(d.happiness)))
                    .enter()
                    .append("circle")
                    .attr("class", `data-point data-point-${index}`)
                    .attr("cx", d => x(d.year) + x.bandwidth() / 2)
                    .attr("cy", d => y(d.happiness))
                    .attr("r", 3)
                    .attr("fill", colorScheme[index])
                    .on("mouseover", function (event, d) {
                        d3.select(this)
                            .transition()
                            .duration(200)
                            .attr("r", 6)
                            .attr("fill", "orange");

                        const tooltipGroup = svg.append("g").attr("class", "tooltip");

                        // 动态背景
                        const text = tooltipGroup
                            .append("text")
                            .attr("x", x(d.year) + x.bandwidth() / 2)
                            .attr("y", y(d.happiness) - 20)
                            .attr("text-anchor", "middle")
                            .attr("font-size", "12px")
                            .attr("fill", "black")
                            .text(`Year: ${d.year}, Happiness: ${d.happiness.toFixed(2)}`);

                        const bbox = text.node().getBBox(); // 获取文字的边界框
                        tooltipGroup
                            .insert("rect", "text")
                            .attr("x", bbox.x - 5)
                            .attr("y", bbox.y - 5)
                            .attr("width", bbox.width + 10)
                            .attr("height", bbox.height + 10)
                            .attr("fill", "white")
                            .attr("stroke", "black")
                            .attr("rx", 5)
                            .attr("ry", 5)
                            .attr("opacity", 0.8);

                        // 添加指向数据点的三角形
                        tooltipGroup
                            .append("polygon")
                            .attr("points", `
                            ${x(d.year) + x.bandwidth() / 2 - 5},${y(d.happiness) - 5} 
                            ${x(d.year) + x.bandwidth() / 2 + 5},${y(d.happiness) - 5} 
                            ${x(d.year) + x.bandwidth() / 2},${y(d.happiness)}`)
                            .attr("fill", "white")
                            .attr("stroke", "black");
                    })
                    .on("mouseout", function () {
                        d3.select(this)
                            .transition()
                            .duration(200)
                            .attr("r", 3)
                            .attr("fill", colorScheme[index]);

                        svg.selectAll(".tooltip").remove(); // 移除提示框
                    });

                // 添加国家标签和图例标志
                svg.append("text")
                    .attr("class", "country-label1")
                    .attr("x",30+index * 160) // 调整位置，避免重叠
                    .attr("y", 15) // 设置在顶部
                    .attr("font-size", "10px")
                    .attr("fill", colorScheme[index])
                    .attr("transform", "rotate(0)") // 横向显示
                    .text(country);

                // 添加图例：线段 + 圆点
                svg.append("line")
                    .attr("class", "legend-line")
                    .attr("x1", 63 + index * 160 ) // 调整位置
                    .attr("y1", 11) // 图例标志在文本右侧
                    .attr("x2", 63 + index * 160 +50) // 线的长度
                    .attr("y2", 11) // 保持在同一水平线
                    .attr("stroke", colorScheme[index])
                    .attr("stroke-width", 3);

                // 添加圆点标志
                svg.append("circle")
                    .attr("class", "legend-dot")
                    .attr("cx", 63 + index * 160 + 25) // 圆点位置
                    .attr("cy", 11)
                    .attr("r", 5) // 圆点半径
                    .attr("fill", colorScheme[index]);
            });
        }


        // 添加更新折线图的函数
        window.updateLineChart = function (country) {
            // 如果国家已经在数组中，则移除它；否则添加它
            const index = selectedCountries.indexOf(country);
            if (index > -1) {
                selectedCountries.splice(index, 1);
            } else {
                if (selectedCountries.length < 3) {
                    selectedCountries.push(country);
                } else {
                    alert("最多只能选择3个国家");
                }
            }

            // 更新图表
            updateChart(data, selectedCountries);
        };

        // 添加清空按钮的事件监听器
        document.getElementById("clearButton").addEventListener("click", function () {
            selectedCountries = [];
            updateChart(data, selectedCountries);
        });
    }).catch(error => {
        console.error("数据加载失败:", error);
    });
});