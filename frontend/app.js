const API_URL = window.APP_CONFIG.apiUrl;

let allKpis = null;
let allCharts = null;
let allFilters = null;

let genreChartInstance = null;
let deviceChartInstance = null;

async function getData(endpoint) {
  const response = await fetch(`${API_URL}${endpoint}`);

  if (!response.ok) {
    throw new Error(`Error en ${endpoint}: ${response.status}`);
  }

  return await response.json();
}

function renderKpis(kpis, selectedGenre = "") {
  document.getElementById("total-watch-time").textContent =
    kpis.total_watch_time + " minutos " ?? "Sin datos";

  document.getElementById("avg-watch-time").textContent =
    kpis.avg_watch_time_per_user + " minutos " ?? "Sin datos";

  const topGenresList = document.getElementById("top-genres");
  topGenresList.innerHTML = "";

  let genresToShow = kpis.top_5_genres || [];

  if (selectedGenre) {
    genresToShow = genresToShow.filter(item => item.genre === selectedGenre);
  }

  if (genresToShow.length === 0) {
    topGenresList.innerHTML = "<li>Sin datos disponibles</li>";
    return;
  }

  genresToShow.forEach(item => {
    const li = document.createElement("li");
    li.textContent = `${item.genre}: ${item.value}`;
    topGenresList.appendChild(li);
  });
}

function renderFilters(filters) {
  const genreFilter = document.getElementById("genreFilter");
  genreFilter.innerHTML = `<option value="">Todos</option>`;

  const genres = filters.genres || [];

  genres.forEach(genre => {
    const option = document.createElement("option");
    option.value = genre;
    option.textContent = genre;
    genreFilter.appendChild(option);
  });
}

function renderGenreChart(charts, selectedGenre = "") {
  const chartDom = document.getElementById("genreChart");

  if (!genreChartInstance) {
    genreChartInstance = echarts.init(chartDom);
  }

  let data = charts.genre_distribution || [];

  if (selectedGenre) {
    data = data.filter(item => item.genre === selectedGenre);
  }

  const option = {
    tooltip: {
      trigger: "axis"
    },
    xAxis: {
      type: "category",
      data: data.map(item => item.genre),
      axisLabel: {
        interval: 0,
        rotate: 30
      }
    },
    yAxis: {
      type: "log",
      name: "Minutos",
      min:900000,
      interval: 10000
    },
    series: [
      {
        data: data.map(item => item.value),
        type: "bar",
        barWidth: "50%"
      }
    ]
  };

  genreChartInstance.setOption(option);
}

function renderDeviceChart(charts, selectedGenre = "") {
  const chartDom = document.getElementById("deviceChart");

  if (!deviceChartInstance) {
    deviceChartInstance = echarts.init(chartDom);
  }

  let data = charts.device_distribution || [];

  // ✅ Filtrar por género
  if (selectedGenre) {
    data = data.filter(item => item.genre === selectedGenre);
  }

  // 🔥 AGRUPAR POR DEVICE (CLAVE)
  const grouped = {};

  data.forEach(item => {
    if (!grouped[item.device]) {
      grouped[item.device] = 0;
    }
    grouped[item.device] += item.value;
  });

  const formattedData = Object.keys(grouped).map(device => ({
    name: device,
    value: grouped[device]
  }));

  const option = {
    tooltip: {
      trigger: "item"
    },
    legend: {
      bottom: 0
    },
    series: [
      {
        name: "Usuarios por dispositivo",
        type: "pie",
        radius: ["40%", "70%"],
        avoidLabelOverlap: true,
        itemStyle: {
          borderRadius: 8,
          borderColor: "#fff",
          borderWidth: 2
        },
        label: {
          show: true,
          formatter: "{b}: {c}"
        },
        data: formattedData
      }
    ]
  };

  deviceChartInstance.setOption(option);
}

function setupFilterEvents() {
  const genreFilter = document.getElementById("genreFilter");

  genreFilter.addEventListener("change", () => {
    const selectedGenre = genreFilter.value;

    renderKpis(allKpis, selectedGenre);
    renderGenreChart(allCharts, selectedGenre);

    renderDeviceChart(allCharts, selectedGenre);
  });
}

async function initDashboard() {
  try {
    const [kpis, charts, filters] = await Promise.all([
      getData("/kpis"),
      getData("/charts"),
      getData("/filters")
    ]);

    allKpis = kpis;
    allCharts = charts;
    allFilters = filters;

    renderKpis(allKpis);
    renderFilters(allFilters);
    renderGenreChart(allCharts);
    renderDeviceChart(allCharts);
    setupFilterEvents();

    window.addEventListener("resize", () => {
      if (genreChartInstance) genreChartInstance.resize();
      if (deviceChartInstance) deviceChartInstance.resize();
    });
  } catch (error) {
    console.error("Error cargando dashboard:", error);

    document.getElementById("total-watch-time").textContent = "Error";
    document.getElementById("avg-watch-time").textContent = "Error";
    document.getElementById("top-genres").innerHTML = "<li>Error cargando datos</li>";
  }
}

initDashboard();