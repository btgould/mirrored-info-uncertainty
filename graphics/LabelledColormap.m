function map = LabelledColormap(points, colors, data)
	% Creates a color map assigning colors to specific values. Points
	% should be an array of the values that should be assigned to a color,
	% and colors should be an array of rgb values for points to be assigned
	% to. Order is preserved.
	% We also need to know the number of elements in the data the map is
	% applied to, so that we know how steep / slow of a gradient to apply
	% between colors.
	arguments (Input)
		points double
		colors(:, 3) double{mustBeGreaterThanOrEqual(colors, 0), mustBeLessThanOrEqual(colors, 1)}
		data double
	end
	arguments (Output)
		map(:, 3) double
	end

	[points, idx] = unique(points);
	colors = colors(idx, :);
	if size(points, 2) > 1
		map = interp1(points, colors, linspace(points(1), points(end), max(size(data))));
	else
		map = colors;
	end
end
