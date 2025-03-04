document.addEventListener("DOMContentLoaded", function () {
  // 数据路径
  const dataPaths = {
    averageData: "average.csv",
    happyData: "happy_avr.CSV",
  };

  let mergedData = [];
  let filteredData = []; // 保存筛选后的数据
  let selectionMode = "single"; // 默认模式为单选模式
  let selectedCountries = new Set(); // 存储多选模式下选中的国家

  // 加载两个 CSV 文件
  Promise.all([d3.csv(dataPaths.averageData), d3.csv(dataPaths.happyData)])
    .then(function ([averageData, happyData]) {
      // 数据整合
      mergedData = averageData.map((row) => {
        return {
          Country: row.Countryname,
          Continent: row.continent, // 假设数据中有 Continent 列
          GDP: +row.GDP,
          Health: +row.Healthy_life_expectancy,
          Generosity: +row.Generosity,
          Perceptions_of_corruption: +row.Perceptions_of_corruption,
          Social_support: +row.Social_support,
          Freedom: +row.Freedom,
          Average: +row.happiness || 0,
        };
      });

      // 定义维度及其含义
      const dimensions = [
        { name: "Average", label: "Happiness Average" },
        { name: "GDP", label: "GDP" },
        { name: "Generosity", label: "Generosity" },
        { name: "Health", label: "Health" },
        { name: "Social_support", label: "Social_support" },
        {
          name: "Perceptions_of_corruption",
          label: "Perceptions_of_corruption",
        },
        { name: "Freedom", label: "Freedom" },
      ];

      // SVG 大小
      const width = 1000,
        height = 800,
        padding = 30;

      // 创建 SVG 容器
      const svg = d3
        .select("#parcoords")
        .append("svg")
        .attr("width", width)
        .attr("height", height);

      // 添加一个覆盖整个SVG区域的矩形
      // 添加一个覆盖整个SVG区域的矩形
      svg
        .append("rect")
        .attr("width", width)
        .attr("height", height)
        .attr("fill", "none")
        .attr("pointer-events", "all")
        .on("mouseout", function () {
          // 恢复所有折线的默认样式
          svg.selectAll("path")
            .style("stroke", (d) => {
              if (!d || !d.Country) return "#ccc"; // 确保 d 和 d.Country 存在
              return selectedCountries.has(d.Country) ? "#2892bc" : "#ccc";
            })
            .style("stroke-width", (d) => {
              if (!d || !d.Country) return 1.5; // 确保 d 和 d.Country 存在
              return selectedCountries.has(d.Country) ? 3 : 1.5;
            });

          // 移除国家名称标签
          svg.selectAll(".country-label").remove();
        });

      // 创建比例尺
      const y = {};
      dimensions.forEach((dim) => {
        y[dim.name] = d3
          .scaleLinear()
          .domain(d3.extent(mergedData, (d) => d[dim.name]))
          .range([height - padding, padding]);
      });

      const x = d3
        .scalePoint()
        .range([padding, width - padding])
        .padding(1)
        .domain(dimensions.map((d) => d.name));

      // 绘制线条函数
      const line = d3
        .line()
        .x((d, i) => x(dimensions[i].name))
        .y((d, i) => y[dimensions[i].name](d));

      // 更新选中国家名字的函数
      function updateSelectedCountriesList() {
        const selectedCountriesArray = Array.from(selectedCountries);
        selectedCountriesArray.sort((a, b) => {
          const countryA = filteredData.find((d) => d.Country === a);
          const countryB = filteredData.find((d) => d.Country === b);
          return countryB.Average - countryA.Average;
        });

        const selectedCountriesList = document.getElementById("selectedCountriesList");
        selectedCountriesList.innerHTML = selectedCountriesArray
          .map((country) => `<div>${country}</div>`)
          .join("");
      }

      // 绘制平行坐标图
      function draw(data) {
        svg.selectAll("path").remove();

        svg
          .selectAll("path")
          .data(data)
          .enter()
          .append("path")
          .attr("d", (d) => line(dimensions.map((dim) => d[dim.name])))
          .style("fill", "none")
          .style("stroke", (d) =>
            selectedCountries.has(d.Country) ? "#2892bc" : "#ccc"
          )
          .style("stroke-width", (d) =>
            selectedCountries.has(d.Country) ? 3 : 1.5
          )
          .style("opacity", 0.7)
          .on("mouseover", function (event, d) {
            if (selectionMode === "single") {
              svg.selectAll("path").style("stroke", "#ccc"); // 将所有折线变灰
              d3.select(this).style("stroke", "#2892bc").style("stroke-width", 3); // 将最近的折线变为蓝色
            }

            // 显示国家名称
            svg.selectAll(".country-label").remove();
            svg
              .append("text")
              .attr("class", "country-label")
              .attr("x", width - 80)
              .attr("y", padding)
              .attr("text-anchor", "end")
              .style("font-size", "16px")
              .style("fill", "black")
              .text(d.Country);
          })
          .on("click", function (event, d) {
            if (selectionMode === "single") {
              selectedCountries.clear();
              selectedCountries.add(d.Country);
              updateLineChart(d.Country); // 调用更新折线图的函数
              draw(filteredData); // 重新绘制平行坐标图以更新选中状态
              drawAxes();
            } else {
              if (selectedCountries.has(d.Country)) {
                selectedCountries.delete(d.Country);
                d3.select(this).style("stroke", "#ccc").style("stroke-width", 1.5); // 恢复颜色
              } else {
                selectedCountries.add(d.Country);
                d3.select(this).style("stroke", "#2892bc").style("stroke-width", 3); // 标亮颜色
              }
              updateSelectedCountriesList(); // 更新选中国家名字列表
            }
          });
      }

      // 添加纵坐标轴和维度标识的函数
      function drawAxes() {
        svg.selectAll(".axis").remove();
        svg
          .selectAll(".axis")
          .data(dimensions)
          .enter()
          .append("g")
          .attr("class", "axis")
          .attr("transform", (d) => `translate(${x(d.name)})`)
          .each(function (d) {
            d3.select(this).call(d3.axisLeft(y[d.name]).tickFormat(() => "")); // 自定义刻度格式，不显示任何文本
          })
          .append("text")
          .style("text-anchor", "middle")
          .attr("y", -20) // 调整标签位置，确保不被遮挡
          .attr("x", 0) // 确保标签在轴的中间
          .text((d) => d.label)
          .style("fill", "black")
          .style("font-size", "12px"); // 确保标签文字大小合适

        // 绘制 x 轴
        svg.select(".x.axis").remove();
        svg
          .append("g")
          .attr("class", "x axis")
          .attr("transform", `translate(0,${height - padding})`)
          .call(
            d3
              .axisBottom(x)
              .tickFormat((d) => dimensions.find((dim) => dim.name === d).label)
          );
      }

      // 更新下拉菜单选项文本
      function updateSelectOptions() {
        const select1 = document.getElementById("column1");
        const select2 = document.getElementById("column2");

        dimensions.forEach((dim, index) => {
          select1.options[index].text = dim.label;
          select2.options[index].text = dim.label;
        });
      }

      // 添加交换列的函数
      function swapColumns(index1, index2) {
        if (
          index1 >= 0 &&
          index1 < dimensions.length &&
          index2 >= 0 &&
          index2 < dimensions.length
        ) {
          // 交换 dimensions 数组中的两个元素
          [dimensions[index1], dimensions[index2]] = [
            dimensions[index2],
            dimensions[index1],
          ];

          // 更新 x 轴的 domain
          x.domain(dimensions.map((d) => d.name));

          // 重新绘制平行坐标图
          draw(filteredData);

          // 重新绘制纵坐标轴和维度标识
          drawAxes();

          // 更新下拉菜单选项文本
          updateSelectOptions();
        }
      }

      // 初始绘制
      filteredData = mergedData; // 初始时，筛选后的数据为全部数据
      draw(filteredData);
      drawAxes();
      updateSelectOptions();

      // 添加交换按钮的事件监听器
      document
        .getElementById("swapButton")
        .addEventListener("click", function () {
          const index1 = parseInt(document.getElementById("column1").value);
          const index2 = parseInt(document.getElementById("column2").value);
          swapColumns(index1, index2);
        });

      // 添加复原按钮的事件监听器
      document
        .getElementById("resetButton")
        .addEventListener("click", function () {
          filteredData = mergedData;
          draw(filteredData);
          drawAxes();
          updateSelectOptions();
        });

      // 添加切换模式按钮的事件监听器
      const toggleModeButton = document.getElementById("toggleModeButton");
      toggleModeButton.textContent = "切换到多选模式"; // 初始按钮文本

      toggleModeButton.addEventListener("click", function () {
        if (selectionMode === "single") {
          selectionMode = "multiple";
          toggleModeButton.textContent = "切换到单选模式";
        } else {
          selectionMode = "single";
          toggleModeButton.textContent = "切换到多选模式";
        }
        draw(filteredData); // 重新绘制平行坐标图
        drawAxes();
      });

      // 添加清空按钮的事件监听器
      document
        .getElementById("clearButton1")
        .addEventListener("click", function () {
          selectedCountries.clear(); // 清空多选模式下的选中国家
          svg.selectAll("path").style("stroke", "#ccc").style("stroke-width", 1.5); // 将所有线变成灰色
          updateSelectedCountriesList(); // 更新选中国家名字列表
        });

      // 更新平行坐标图数据
      window.updateParallelCoordinatesByCountry = function (country) {
        const continent = mergedData.find(
          (d) => d.Country === country
        )?.Continent;
        if (continent) {
          filteredData = mergedData.filter(
            (d) => d.Continent === continent
          );
          draw(filteredData);
          drawAxes(); // 重新绘制纵坐标轴和维度标识
        }
      };

      // 筛选前40%的函数
      function filterTop50Percent(data, metric) {
        const sortedData = data.sort((a, b) => b[metric] - a[metric]);
        const top50PercentIndex = Math.floor(sortedData.length * 0.4);
        return sortedData.slice(0, top50PercentIndex);
      }

      // 添加筛选按钮的事件监听器
      document
        .getElementById("filterButton")
        .addEventListener("click", function () {
          const selectedMetric = document.getElementById("metric-select").value;
          filteredData = filterTop50Percent(mergedData, selectedMetric);
          draw(filteredData);
          drawAxes(); // 重新绘制纵坐标轴和维度标识
        });

      // 添加选择框的事件监听器
      d3.select("#continent-select").on("change", function () {
        const selectedContinent = this.value;
        filteredData =
          selectedContinent === "All"
            ? mergedData
            : mergedData.filter((d) => d.Continent === selectedContinent);
        draw(filteredData);
        drawAxes(); // 重新绘制纵坐标轴和维度标识
      });
    })
    .catch((error) => {
      console.error("数据加载失败:", error);
    });
});