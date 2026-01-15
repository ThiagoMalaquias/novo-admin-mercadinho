import { Controller } from "@hotwired/stimulus"
import { Chart, registerables } from "chart.js"

Chart.register(...registerables)

// Connects to data-controller="home"
export default class extends Controller {
  static targets = []

  connect() {
    this.initRevenueChart()
  }

  updatePeriod(event) {
    const period = event.target.value
    const data = this.getDataForPeriod(period)
    const labels = this.getLabelsForPeriod(period)

    this.revenueChart.data.labels = labels
    this.revenueChart.data.datasets[0].data = data
    this.revenueChart.update()
  }

  getDataForPeriod(period) {
    // Dados de exemplo - você pode substituir por dados reais da API
    if (period === '6') {
      return [45000, 60000, 75000, 55000, 85000, 100000]
    } else if (period === '12') {
      return [35000, 42000, 45000, 60000, 75000, 55000, 85000, 100000, 95000, 88000, 92000, 105000]
    } else {
      // Este ano (meses até o mês atual)
      const currentMonth = new Date().getMonth() + 1
      const data = []
      for (let i = 1; i <= currentMonth; i++) {
        data.push(Math.floor(Math.random() * 50000) + 50000)
      }
      return data
    }
  }

  getLabelsForPeriod(period) {
    const monthNames = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez']

    if (period === '6') {
      return monthNames.slice(0, 6)
    } else if (period === '12') {
      return monthNames
    } else {
      const currentMonth = new Date().getMonth() + 1
      return monthNames.slice(0, currentMonth)
    }
  }

  initRevenueChart() {
    const ctx = document.getElementById('revenueChart')
    if (!ctx) return

    const isDarkMode = document.documentElement.classList.contains('dark')
    const textColor = isDarkMode ? '#e5e7eb' : '#111827'
    const gridColor = isDarkMode ? '#374151' : '#e5e7eb'

    this.revenueChart = new Chart(ctx, {
      type: 'bar',
      data: {
        labels: ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun'],
        datasets: [{
          label: 'Receita (R$)',
          data: [45000, 60000, 75000, 55000, 85000, 100000],
          backgroundColor: [
            'rgba(59, 130, 246, 0.5)',
            'rgba(59, 130, 246, 0.6)',
            'rgba(59, 130, 246, 0.7)',
            'rgba(59, 130, 246, 0.8)',
            'rgba(59, 130, 246, 0.9)',
            'rgba(59, 130, 246, 1)'
          ],
          borderColor: [
            'rgba(59, 130, 246, 1)',
            'rgba(59, 130, 246, 1)',
            'rgba(59, 130, 246, 1)',
            'rgba(59, 130, 246, 1)',
            'rgba(59, 130, 246, 1)',
            'rgba(59, 130, 246, 1)'
          ],
          borderWidth: 1,
          borderRadius: 4
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            display: false
          },
          tooltip: {
            backgroundColor: isDarkMode ? '#1f2937' : '#ffffff',
            titleColor: textColor,
            bodyColor: textColor,
            borderColor: gridColor,
            borderWidth: 1,
            callbacks: {
              label: function (context) {
                return 'R$ ' + context.parsed.y.toLocaleString('pt-BR')
              }
            }
          }
        },
        scales: {
          y: {
            beginAtZero: true,
            ticks: {
              color: textColor,
              callback: function (value) {
                return 'R$ ' + (value / 1000).toFixed(0) + 'k'
              }
            },
            grid: {
              color: gridColor
            }
          },
          x: {
            ticks: {
              color: textColor
            },
            grid: {
              color: gridColor,
              display: false
            }
          }
        }
      }
    })

    // Observar mudanças no dark mode
    const observer = new MutationObserver(() => {
      const isDark = document.documentElement.classList.contains('dark')
      const newTextColor = isDark ? '#e5e7eb' : '#111827'
      const newGridColor = isDark ? '#374151' : '#e5e7eb'

      this.revenueChart.options.scales.y.ticks.color = newTextColor
      this.revenueChart.options.scales.y.grid.color = newGridColor
      this.revenueChart.options.scales.x.ticks.color = newTextColor
      this.revenueChart.options.scales.x.grid.color = newGridColor
      this.revenueChart.options.plugins.tooltip.backgroundColor = isDark ? '#1f2937' : '#ffffff'
      this.revenueChart.options.plugins.tooltip.titleColor = newTextColor
      this.revenueChart.options.plugins.tooltip.bodyColor = newTextColor
      this.revenueChart.options.plugins.tooltip.borderColor = newGridColor
      this.revenueChart.update()
    })

    observer.observe(document.documentElement, {
      attributes: true,
      attributeFilter: ['class']
    })
  }
}
