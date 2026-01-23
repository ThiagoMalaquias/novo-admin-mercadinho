import { Controller } from "@hotwired/stimulus"
import { Chart, registerables } from "chart.js"

Chart.register(...registerables)

// Connects to data-controller="formas-recebimento-chart"
export default class extends Controller {
  static targets = ["canvas"]
  static values = {
    credito: Number,
    debito: Number,
    pix: Number,
    sodexo: Number
  }

  connect() {
    this.initChart()
    this.setupDarkModeObserver()
  }

  disconnect() {
    if (this.chart) {
      this.chart.destroy()
    }
    if (this.darkModeObserver) {
      this.darkModeObserver.disconnect()
    }
  }

  initChart() {
    const ctx = this.canvasTarget
    if (!ctx) return

    const isDark = document.documentElement.classList.contains('dark')
    const textColor = '#E5E7EB'
    const gridColor = '#374151'

    this.chart = new Chart(ctx, {
      type: 'pie',
      data: {
        labels: [
          'CREDITO',
          'DEBITO',
          'PIX',
          'VA SODEXO'
        ],
        datasets: [{
          label: 'Valor',
          data: [
            this.creditoValue,
            this.debitoValue,
            this.pixValue,
            this.sodexoValue
          ],
          backgroundColor: [
            '#5B98B6',
            '#FF6600',
            '#5A736F',
            '#FDD752'
          ],
          borderColor: isDark ? '#1F2937' : '#FFFFFF',
          borderWidth: 2,
          hoverOffset: 8
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: true,
        plugins: {
          legend: {
            position: 'bottom',
            labels: {
              color: textColor,
              padding: 15,
              font: {
                size: 12
              }
            }
          },
          tooltip: {
            backgroundColor: isDark ? '#1F2937' : '#FFFFFF',
            titleColor: textColor,
            bodyColor: textColor,
            borderColor: gridColor,
            borderWidth: 1,
            padding: 12,
            callbacks: {
              label: (context) => {
                const label = context.label || ''
                const value = context.parsed || 0
                const total = context.dataset.data.reduce((a, b) => a + b, 0)
                const percentage = total > 0 ? ((value / total) * 100).toFixed(1) : 0
                return label + ': ' + new Intl.NumberFormat('pt-BR', {
                  style: 'currency',
                  currency: 'BRL'
                }).format(value / 100.0) + ' (' + percentage + '%)'
              }
            }
          }
        }
      }
    })
  }

  setupDarkModeObserver() {
    this.darkModeObserver = new MutationObserver(() => {
      if (!this.chart) return

      const isDark = document.documentElement.classList.contains('dark')
      const textColor = '#E5E7EB'
      const gridColor = '#374151'

      this.chart.options.plugins.legend.labels.color = textColor
      this.chart.options.plugins.tooltip.backgroundColor = isDark ? '#1F2937' : '#FFFFFF'
      this.chart.options.plugins.tooltip.titleColor = textColor
      this.chart.options.plugins.tooltip.bodyColor = textColor
      this.chart.options.plugins.tooltip.borderColor = gridColor
      this.chart.data.datasets[0].borderColor = isDark ? '#1F2937' : '#FFFFFF'
      this.chart.update()
    })

    this.darkModeObserver.observe(document.documentElement, {
      attributes: true,
      attributeFilter: ['class']
    })
  }
}
