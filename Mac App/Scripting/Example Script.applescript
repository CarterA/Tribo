tell application "Tribo"
	
	-- The basic Tribo object structure --
	
	set theDocument to the document named "Blog.tribo"
	set theSite to the site of theDocument
	set thePost to the first post of theSite
	
	-- Tribo text can be accessed and parsed using the Text Suit commands --
	
	get first paragraph of the markdown content of thePost
	
	-- Document previewing can be started and stopped using commands in either format --
	
	start preview of theDocument
	tell theDocument to stop preview
	
end tell