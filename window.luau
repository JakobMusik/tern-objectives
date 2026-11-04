--!strict
-- Objectives: window half. Registers the palette commands and canvas handlers.

tern.command({
	id = "open",
	title = "Objectives: Open graph",
	group = "Objectives",
	keys = { "ctrl+cmd+o" },
	run = function(cx)
		cx:toast("info", "Objectives: graph not built yet")
	end,
})
