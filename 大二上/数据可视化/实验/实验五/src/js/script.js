const width = 640;
const height = 400;

const svg = d3.select("#map").attr("width", width).attr("height", height);

// 投影设置
let isSphere = true; // 初始设置为球形地图
let projection = d3
  .geoOrthographic()
  .scale(200)
  .translate([width / 2, height / 2])
  .rotate([-104.1954, -35.8617]); // 设置中国为中心

const path = d3.geoPath().projection(projection);

const tooltip = d3
  .select("body")
  .append("div")
  .attr("class", "tooltip")
  .style("opacity", 0);

// 加载幸福指数数据
d3.csv("average.csv")
  .then(function (happinessData) {
    const happinessByCountry = {};
    happinessData.forEach(function (d) {
      happinessByCountry[d.Countryname] = +d.happiness;
    });

    // 加载世界地图数据
    d3.json("src/data/world.geojson")
      .then(function (worldData) {
        const colorScale = d3
          .scaleSequential(d3.interpolateGreens)
          .domain(d3.extent(happinessData, (d) => +d.happiness));

        // 添加蓝色背景路径
        svg
          .append("path")
          .datum({ type: "Sphere" })
          .attr("class", "sphere")
          .attr("d", path)
          .attr("fill", "lightblue");

        // 绘制世界地图
        const mapPaths = svg
          .selectAll("path.country")
          .data(worldData.features)
          .enter()
          .append("path")
          .attr("class", "country")
          .attr("d", path)
          .attr("fill", function (d) {
            const countryName = d.properties.name;
            const happinessValue = happinessByCountry[countryName];
            return happinessValue ? colorScale(happinessValue) : "#ccc";
          })
          .attr("stroke", "#fff")
          .attr("opacity", 1)
          .on("mouseover", function (event, d) {
            const countryName = d.properties.name;
            const happinessValue = happinessByCountry[countryName];

            d3.select(this)
              .transition()
              .duration(200)
              .attr("transform", function (d) {
                const [x, y] = path.centroid(d);
                return `translate(${x},${y}) scale(1.1) translate(${-x},${-y})`;
              });

            tooltip.transition().duration(200).style("opacity", 0.9);
            tooltip
              .html(`${countryName}<br>幸福指数: ${happinessValue || "无数据"}`)
              .style("left", event.pageX + "px")
              .style("top", event.pageY - 28 + "px");
          })
          .on("mouseout", function (event, d) {
            d3.select(this)
              .transition()
              .duration(200)
              .attr("transform", "translate(0,0)");

            tooltip.transition().duration(500).style("opacity", 0);
          })
          .on("click", function (event, d) {
            const countryName = d.properties.name; // 获取国家名称
            updateParallelCoordinatesByCountry(countryName);
            updateLineChart(countryName);
          });

        // 添加切换投影按钮的事件监听器
        d3.select("body")
          .append("button")
          .attr("id", "toggleProjection")
          .attr("class", "button")
          .text("切换投影")
          .on("click", function () {
            isSphere = !isSphere;
            projection = isSphere
              ? d3
                  .geoOrthographic()
                  .scale(200)
                  .translate([width / 2, height / 2])
                  .rotate([-104.1954, -35.8617])
              : d3
                  .geoNaturalEarth1()
                  .scale(100)
                  .translate([width / 2, height / 2])
                  .center([0, 0]);
            path.projection(projection);

            svg
              .selectAll("path.country")
              .transition()
              .duration(1500) // 增加过渡时间
              .ease(d3.easeCubicInOut) // 使用平滑过渡效果
              .attr("d", path)
              .attr("opacity", function (d) {
                return isSphere
                  ? d3.geoContains({ type: "Sphere" }, d)
                    ? 1
                    : 0
                  : 1;
              });

            // 直接更新背景路径的投影
            svg.select("path.sphere").attr("d", path);

            if (isSphere) {
              startAutoRotate();
            } else {
              stopAutoRotate();
            }
          });

        let timer;
        function startAutoRotate() {
          timer = d3.timer(function (elapsed) {
            const rotate = projection.rotate();
            rotate[0] += 0.2; // 调整旋转速度
            projection.rotate(rotate);
            svg.selectAll("path.country").attr("d", path);
            svg.select("path.sphere").attr("d", path);
          });
        }

        function stopAutoRotate() {
          if (timer) timer.stop();
        }

        // 添加旋转暂停按钮
        let isRotating = true;
        d3.select("body")
          .append("button")
          .attr("id", "toggleRotation")
          .attr("class", "button")
          .text("暂停旋转")
          .on("click", function () {
            if (isRotating) {
              stopAutoRotate();
              d3.select(this).text("继续旋转");
            } else {
              startAutoRotate();
              d3.select(this).text("暂停旋转");
            }
            isRotating = !isRotating;
          });

        // 添加圆形控件用于手动旋转
        const drag = d3
          .drag()
          .on("start", function (event) {
            stopAutoRotate();
          })
          .on("drag", function (event) {
            const rotate = projection.rotate();
            if (isSphere) {
              rotate[0] += event.dx * 0.5; // 调整旋转速度
              rotate[1] -= event.dy * 0.5; // 调整旋转速度
            } else {
              rotate[0] += event.dx * 0.5; // 仅左右移动
            }
            projection.rotate(rotate);
            svg.selectAll("path.country").attr("d", path);
            svg.select("path.sphere").attr("d", path);
          })
          .on("end", function (event) {
            if (isSphere && isRotating) {
              startAutoRotate();
            }
          });

        svg
          .append("circle")
          .attr("cx", width - 50)
          .attr("cy", height - 50)
          .attr("r", 40)
          .attr("fill", "#28a745")
          .call(drag);

        // 启动自动旋转
        startAutoRotate();
      })
      .catch(function (error) {
        console.error("Error loading world map data:", error);
      });
  })
  .catch(function (error) {
    console.error("Error loading happiness data:", error);
  });
