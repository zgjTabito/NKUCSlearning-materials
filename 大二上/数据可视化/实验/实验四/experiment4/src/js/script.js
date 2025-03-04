// 数据部分
const data = [
    { "province": "黑龙江", "count": 1, "latitude": 45.7567 },
    { "province": "吉林", "count": 1, "latitude": 43.8860 },
    { "province": "辽宁", "count": 4, "latitude": 41.8057 },
    { "province": "北京", "count": 1, "latitude": 39.9042 },
    { "province": "天津", "count": 15, "latitude": 39.3434 },
    { "province": "河北", "count": 6, "latitude": 38.0428 },
    { "province": "山西", "count": 2, "latitude": 37.8570 },
    { "province": "山东", "count": 9, "latitude": 36.6758 },
    { "province": "河南", "count": 13, "latitude": 34.7466 },
    { "province": "江苏", "count": 5, "latitude": 32.0603 },
    { "province": "安徽", "count": 3, "latitude": 31.8616 },
    { "province": "湖北", "count": 6, "latitude": 30.5931 },
    { "province": "四川", "count": 6, "latitude": 30.5728 },
    { "province": "重庆", "count": 3, "latitude": 29.4316 },
    { "province": "江西", "count": 5, "latitude": 28.6758 },
    { "province": "湖南", "count": 1, "latitude": 28.1941 },
    { "province": "贵州", "count": 1, "latitude": 26.6477 },
    { "province": "福建", "count": 5, "latitude": 26.0753 },
    { "province": "云南", "count": 1, "latitude": 25.0453 },
    { "province": "广东", "count": 3, "latitude": 23.1291 },
    { "province": "海外", "count": 3, "latitude": 0 }
];

const svg = d3.select("#flow-chart");
const width = svg.attr("width");
const height = svg.attr("height");

const tooltip = d3.select(".tooltip");

// Y 轴比例尺：根据省份顺序在垂直方向排列条形图
const yScale = d3.scaleBand()
    .domain(data.map(d => d.province))
    .range([30, height - 100])
    .padding(0.1);

// X 轴比例尺：根据人数映射条形图的宽度
const xScale = d3.scaleLinear()
    .domain([0, d3.max(data, d => d.count)])
    .range([0, width / 4]); // 将条形图的宽度限制在总宽度的 1/4

// 颜色比例尺：从蓝到红的渐变，纬度越高颜色越冷，纬度越低颜色越暖
const colorScale = d3.scaleLinear()
    .domain([23.1291, d3.max(data, d => d.latitude)])
    .range(["#ff6b6b", "#1f78b4"]); // 红色到蓝色的渐变

// 绘制条形图
svg.selectAll(".bar")
    .data(data)
    .enter()
    .append("rect")
    .attr("class", "bar")
    .attr("x", width / 4) // 条形图的起点，居中
    .attr("y", d => yScale(d.province))
    .attr("width", d => xScale(d.count)) // 条形图宽度根据人数确定
    .attr("height", yScale.bandwidth()) // 条形图的高度
    .attr("fill", d => colorScale(d.latitude)) // 根据纬度设置条形颜色
    .on("mouseover", function (event, d) {
        // 显示提示信息
        tooltip.style("display", "block")
            .html(`省份: ${d.province}<br>人数: ${d.count}<br>维度:${d.latitude}`)
            .style("left", (event.pageX + 5) + "px")
            .style("top", (event.pageY - 28) + "px");
    })
    .on("mouseout", () => tooltip.style("display", "none"));

// 绘制省份名称
svg.selectAll(".province-text")
    .data(data)
    .enter()
    .append("text")
    .attr("class", "province-text")
    .attr("x", width / 4 - 10) // 文字在条形图的左侧
    .attr("y", d => yScale(d.province) + yScale.bandwidth() / 2)
    .attr("dy", "0.35em")
    .style("text-anchor", "end")
    .text(d => d.province)
    .attr("fill", "#333");

const tianjinBarHeight = yScale.bandwidth();
const tianjinBarY = yScale("天津") + tianjinBarHeight / 2 - tianjinBarHeight / 2;
const tianjinPosition = { x: width - 100, y: tianjinBarY };


data.forEach(d => {
    const barEndX = width / 4 + xScale(d.count); // 条形图右端的 X 坐标
    const barCenterY = yScale(d.province) + yScale.bandwidth() / 2; // 条形图中心的 Y 坐标
    const unifiedControlX = width / 1.4; // 统一竖直线的 X 坐标（可调整）

    svg.append("path")
        .attr("class", "line")
        .attr("d", `M ${barEndX} ${barCenterY} 
                    C ${unifiedControlX} ${barCenterY}, 
                      ${unifiedControlX} ${tianjinPosition.y + tianjinBarHeight / 2}, 
                      ${tianjinPosition.x} ${tianjinPosition.y}`)
        .attr("stroke", colorScale(d.latitude)) // 线条颜色根据纬度设置
        .attr("stroke-width", 2) // 固定线条宽度
        .attr("stroke-width", d.count * 0.7) // 曲线宽度根据生源人数映射
        .attr("stroke-opacity", 0.6) // 半透明效果
        .attr("fill", "none");
});


svg.append("circle")
    .attr("class", "circle")
    .attr("cx", tianjinPosition.x)
    .attr("cy", tianjinPosition.y)
    .attr("r", 6)
    .attr("fill", "#333")
    .on("mouseover", function (event) {
        // 显示提示信息
        tooltip.style("display", "block")
            .html(`总人数: 100`)
            .style("left", (event.pageX + 5) + "px")
            .style("top", (event.pageY - 28) + "px");
    })
    .on("mouseout", () => tooltip.style("display", "none"));

// 添加横轴
svg.append("g")
    .attr("transform", `translate(${width / 4}, ${height - 60})`)
    .call(d3.axisBottom(xScale).ticks(5))
    .append("text")
    .attr("x", 120)
    .attr("y", 40)
    .attr("text-anchor", "middle")
    .attr("fill", "#333")
    .attr("font-size", "14px")
    .text("人数分布");

// 添加纵轴标签
svg.append("text")
    .attr("transform", "rotate(-90)")
    .attr("x", -height / 2)
    .attr("y", width / 4 - 80)
    .attr("dy", "1em")
    .style("text-anchor", "middle")
    .attr("fill", "#333")
    .attr("font-size", "14px")
    .text("省份");

// 添加渐变颜色条图例
const defs = svg.append("defs");

const linearGradient = defs.append("linearGradient")
    .attr("id", "linear-gradient")
    .attr("x1", "0%")
    .attr("y1", "100%")
    .attr("x2", "0%")
    .attr("y2", "0%"); // 从上到下渐变
linearGradient.selectAll("stop")
    .data([
        { offset: "0%", color: "#ff6b6b" },
        { offset: "100%", color: "#1f78b4" }
    ])
    .enter()
    .append("stop")
    .attr("offset", d => d.offset)
    .attr("stop-color", d => d.color);

svg.append("rect")
    .attr("x", width - 200)
    .attr("y", 260)
    .attr("width", 20)
    .attr("height", 200)
    .style("fill", "url(#linear-gradient)");

svg.append("text")
    .attr("x", width - 150)
    .attr("y", 240)
    .attr("dy", "0.35em")
    .style("text-anchor", "start")
    .text("纬度");

svg.append("text")
    .attr("x", width - 160)
    .attr("y", 260)
    .attr("dy", "0.35em")
    .style("text-anchor", "start")
    .text(d3.max(data, d => d.latitude));

svg.append("text")
    .attr("x", width - 160)
    .attr("y", 450)
    .attr("dy", "0.35em")
    .style("text-anchor", "start")
    .text(23.1291);

// 环形图数据部分
const chartData = [
    { country: '美国', count: 429 },
    { country: '英国', count: 132 },
    { country: '法国', count: 78 },
    { country: '德国', count: 75 },
    { country: '瑞典', count: 36 },
    { country: '日本', count: 30 }
];

const totalCount = d3.sum(chartData, d => d.count);
const svgWidth = 1000;
const svgHeight = 600;
const outerRadius = Math.min(svgWidth, svgHeight) / 2 - 50;

// 设置颜色比例尺，每个大洲使用不同的色系
const continentColorScales = {
    '北美洲': d3.scaleSequential(d3.interpolateBlues).domain([0, 1]),
    '欧洲': d3.scaleSequential(d3.interpolateReds).domain([0, 1]),
    '亚洲': d3.scaleSequential(d3.interpolateGreens).domain([0, 1])
};

// 定义每个国家所属的大洲
const countryContinent = {
    '美国': '北美洲',
    '英国': '欧洲',
    '法国': '欧洲',
    '德国': '欧洲',
    '瑞典': '欧洲',
    '日本': '亚洲'
};

// 计算每个大洲内的国家索引
const continentIndex = {};
chartData.forEach((d, i) => {
    const continent = countryContinent[d.country];
    if (!continentIndex[continent]) {
        continentIndex[continent] = [];
    }
    continentIndex[continent].push(i);
});

// 定义颜色比例尺 colorScale1
const colorScale1 = d3.scaleOrdinal()
    .domain(chartData.map(d => d.country))
    .range(chartData.map(d => {
        const continent = countryContinent[d.country];
        const index = continentIndex[continent].indexOf(chartData.indexOf(d));
        const scale = continentColorScales[continent];
        return continentIndex[continent].length > 1 
            ? scale(index / (continentIndex[continent].length - 1)) 
            : scale(0.5); // 对于只有一个国家的情况，使用中间值
    }));

// 创建 SVG 容器
const svgContainer = d3.select("#donutChart")
    .append("svg")
    .attr("width", svgWidth)
    .attr("height", svgHeight)
    .append("g")
    .attr("transform", `translate(${svgWidth / 2}, ${svgHeight / 2})`);

// 创建弧生成器
const arcGenerator = d3.arc()
    .innerRadius(outerRadius * 0.6)
    .outerRadius(outerRadius);

const outerArcGenerator = d3.arc()
    .innerRadius(outerRadius * 0.85)  // 外环的半径调整为0.85，以更清晰展示引导线
    .outerRadius(outerRadius * 0.85);

// 饼图生成器
const pieGenerator = d3.pie()
    .sort(null)
    .value(d => d.count);

// 绘制环形图
svgContainer.selectAll("path")
    .data(pieGenerator(chartData))
    .enter()
    .append("path")
    .attr("d", arcGenerator)
    .attr("fill", d => colorScale1(d.data.country))
    .attr("stroke", "white")
    .attr("stroke-width", 2)
    .on("mouseover", function (event, d) {
        d3.select(this)
            .transition()
            .duration(200)
            .attr("transform", "scale(1.1)");

        // 显示详细信息
        d3.select(".nobel-tooltip").style("opacity", 1)
            .html(`${d.data.country}: ${d.data.count} (${((d.data.count / totalCount) * 100).toFixed(2)}%)`)
            .style("left", (event.pageX + 10) + "px")
            .style("top", (event.pageY - 25) + "px");
    })
    .on("mouseout", function () {
        d3.select(this)
            .transition()
            .duration(200)
            .attr("transform", "scale(1)");

        d3.select(".nobel-tooltip").style("opacity", 0);
    });

// 添加总数到中心区域，调整字体大小和样式
svgContainer.append("text")
    .attr("text-anchor", "middle")
    .style("font-size", "22px")
    .style("font-weight", "bold")
    .style("fill", "#333")
    .text(`总计: ${totalCount}`);

// 添加引导线并优化曲线
svgContainer.selectAll("polyline")
    .data(pieGenerator(chartData))
    .enter()
    .append("polyline")
    .attr("stroke", "gray")
    .attr("stroke-width", 1.5) // 加粗线条
    .attr("fill", "none")
    .attr("points", function (d) {
        const posA = arcGenerator.centroid(d); // 扇形内的中心
        const posB = outerArcGenerator.centroid(d); // 环外的中心
        const posC = outerArcGenerator.centroid(d); // 标签位置
        const midAngle = d.startAngle + (d.endAngle - d.startAngle) / 2;
        
        // 调整 posC[0] 位置，使标签离图形更远
        posC[0] = outerRadius * 1.2 * (midAngle < Math.PI ? 1 : -1); // 标签位置更远
        return [posA, posB, posC];
    });

// 设置总数提示框
const tooltip1 = d3.select("body").append("div")
    .attr("class", "nobel-tooltip")
    .style("position", "absolute")
    .style("padding", "8px")
    .style("background", "rgba(0, 0, 0, 0.7)")
    .style("color", "#fff")
    .style("border-radius", "4px")
    .style("font-size", "12px")
    .style("pointer-events", "none")
    .style("opacity", 0);

// 绘制环形图
svgContainer.selectAll("path")
    .data(pieGenerator(chartData))
    .enter()
    .append("path")
    .attr("d", arcGenerator)
    .attr("fill", d => colorScale1(d.data.country))
    .attr("stroke", "white")
    .attr("stroke-width", 2)
    .on("mouseover", function (event, d) {
        d3.select(this)
            .transition()
            .duration(200)
            .attr("transform", "scale(1.1)"); // 放大效果

        // 显示详细信息
        tooltip1.style("opacity", 1)
            .html(`${d.data.country}: ${d.data.count} (${((d.data.count / totalCount) * 100).toFixed(2)}%)`)
            .style("left", (event.pageX + 10) + "px")
            .style("top", (event.pageY - 25) + "px");
    })
    .on("mousemove", function (event) {
        tooltip1.style("left", (event.pageX + 10) + "px")
               .style("top", (event.pageY - 25) + "px");
    })
    .on("mouseout", function () {
        d3.select(this)
            .transition()
            .duration(200)
            .attr("transform", "scale(1)"); // 恢复原大小

        tooltip1.style("opacity", 0); // 隐藏提示框
    });

// 添加引导线
svgContainer.selectAll("polyline")
    .data(pieGenerator(chartData))
    .enter()
    .append("polyline")
    .attr("stroke", "gray")
    .attr("stroke-width", 1.5)
    .attr("fill", "none")
    .attr("points", function (d) {
        const posA = arcGenerator.centroid(d);
        const posB = outerArcGenerator.centroid(d);
        const posC = outerArcGenerator.centroid(d);
        const midAngle = d.startAngle + (d.endAngle - d.startAngle) / 2;
        posC[0] = outerRadius * 1.2 * (midAngle < Math.PI ? 1 : -1);
        return [posA, posB, posC];
    });

// 添加标签
svgContainer.selectAll("text.label")
    .data(pieGenerator(chartData))
    .enter()
    .append("text")
    .attr("class", "label")
    .attr("text-anchor", d => (d.startAngle + d.endAngle) / 2 < Math.PI ? "start" : "end")
    .attr("transform", function (d) {
        const labelPos = outerArcGenerator.centroid(d);
        const midAngle = d.startAngle + (d.endAngle - d.startAngle) / 2;
        labelPos[0] = outerRadius * 1.2 * (midAngle < Math.PI ? 1 : -1);
        return `translate(${labelPos})`;
    })
    .text(d => `${d.data.country}: ${((d.data.count / totalCount) * 100).toFixed(2)}%`)
    .style("font-size", "14px")
    .style("fill", "#333");
