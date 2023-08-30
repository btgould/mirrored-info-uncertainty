function FormatHeatmap(heatmap)
	%FormatPlot Formats a plot with LaTeX interpreters
	heatmap.GridVisible = false;

	% Change labels
	heatmap.XDisplayLabels(1) = {"$0$"};
	heatmap.XDisplayLabels(2:end-1) = {NaN};
	heatmap.XDisplayLabels(end) = {"$1 - p(0)~~~~~~~$"};
	heatmap.YDisplayLabels(1) = {"$1 - p(0)~~~~~~~$"};
	heatmap.YDisplayLabels(2:end-1) = {NaN};
	heatmap.YDisplayLabels(end) = {"$0$"};

	% Change font settings
	ax = heatmap.NodeChildren(3);
	ax.XAxis.TickLabelInterpreter = "latex";
	ax.XAxis.FontSize = 10;
	ax.XLabel.Interpreter = "latex";
	ax.XLabel.FontSize = 14;
	ax.YAxis.TickLabelInterpreter = "latex";
	ax.YAxis.FontSize = 10;
	ax.YLabel.Interpreter = "latex";
	ax.YLabel.FontSize = 14;
	ax.Title.Interpreter = "latex";
	ax.Title.FontSize = 15;

	% Change color settings 
	ax.Parent.Parent.Color = [1 1 1];

    % Change tick label direction
    set(struct(heatmap).NodeChildren(3), 'XTickLabelRotation', 0);
    set(struct(heatmap).NodeChildren(3), 'YTickLabelRotation', 90);
end