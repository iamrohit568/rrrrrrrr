export const getInsightsChartOptions = () => {
	const formatDollar = value =>
		`$${value?.toLocaleString(undefined, { minimumFractionDigits: 0 })}`;

	const topValuePlugin = {
		id: 'topValue',
		afterDatasetsDraw(chart) {
			const { ctx, data, chartArea } = chart;
			ctx.save(); // Save the current context state
			ctx.font = 'bold 12px sans-serif';
			ctx.textBaseline = 'middle';
			ctx.fillStyle = '#000';
			
			chart.getDatasetMeta(0).data.forEach((datapoint, index) => {
				const value = data.datasets[0].data[index];
				const formattedValue = formatDollar(value);
				const textWidth = ctx.measureText(formattedValue).width;
				
				// Calculate positions based on actual text width
				const PADDING = 8; // Consistent padding
				
				let xCoordinate;
				let textAlign;
				
				if (value >= 0) {
					// For positive values: position to the right of the bar
					xCoordinate = datapoint.x + PADDING;
					textAlign = 'left';
				} else {
					// For negative values: position to the left of the bar
					// Use the bar's left edge (x position) minus padding
					xCoordinate = datapoint.base - PADDING;
					textAlign = 'right';
					
					// Ensure text doesn't go beyond the left edge of the chart area
					if (xCoordinate - textWidth < chartArea.left) {
						xCoordinate = chartArea.left + PADDING;
						textAlign = 'left';
					}
				}
				
				ctx.textAlign = textAlign;
				ctx.fillText(formattedValue, xCoordinate, datapoint.y);
			});
			ctx.restore(); // Restore the context state
		},
	};

	return {
		barThickness: 'flex',
		maxBarThickness: 30,
		maintainAspectRatio: false,
		scales: {
			y: {
				ticks: {
					maxRotation: 45,
					minRotation: 0,
				},
				title: {
					display: true,
					color: '#9c9c9c',
					padding: 20,
					font: {
						size: 12,
					},
				},
				grid: {
					display: false,
				},
			},
			x: {
				ticks: {
					callback: formatDollar,
				},
				border: {
					display: false,
				},
				// Add suggested min to ensure negative values have enough space
				suggestedMin: -2000, // Increased to accommodate larger negative values
			},
		},
		plugins: {
			legend: {
				display: false,
			},
			tooltip: {
				callbacks: {
					label: context => ` $${context.formattedValue}`,
				},
			},
		},
		// Increase padding on both sides to accommodate labels
		layout: {
			padding: {
				left: 140, // Increased for larger negative values
				right: 120,
			},
		},
		indexAxis: 'y',
		extPlugins: topValuePlugin,
	};
};
