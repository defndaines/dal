#!/usr/bin/env lua

local tag = require("tag")

-- parsing

local list = "nonfiction, social justice, memoir, politics, history"
local tags = tag.parse(list)

assert(list == table.concat(tags, ", "), table.concat(tags, ", "))

-- nonfiction always first

tags = tag.sort(tags)
assert("nonfiction" == tags[1])
assert("nonfiction, memoir, history, politics, social justice" == table.concat(tags, ", "), table.concat(tags, ", "))

-- format second

list = "nonfiction, race, memoir, essays, poetry, music"
tags = tag.sort(tag.parse(list))

assert("nonfiction" == tags[1])
assert("essays" == tags[2])
assert("nonfiction, essays, poetry, memoir, race, music" == table.concat(tags, ", "), table.concat(tags, ", "))

-- Try to hit all 17 categories
tags = tag.sort(tag.parse("classics, literary, romance, historical, war, 1939 refugee in Paris"))
assert(
	"classics, literary, historical, romance, war, 1939 refugee in Paris" == table.concat(tags, ", "),
	table.concat(tags, ", ")
)

tags = tag.sort(tag.parse("sci-fi, queer, LGBT, space opera, wayfarers-2"))
assert("sci-fi, LGBT, space opera, queer, wayfarers-2" == table.concat(tags, ", "), table.concat(tags, ", "))

tags = tag.sort(tag.parse("literary, historical, race, Black, 1973 Alabama"))
assert("literary, historical, Black, race, 1973 Alabama" == table.concat(tags, ", "), table.concat(tags, ", "))

tags = tag.sort(tag.parse("nonfiction, war, history, politics, biography, Pulitzer Prize"))
assert(
	"nonfiction, history, biography, war, politics, Pulitzer Prize" == table.concat(tags, ", "),
	table.concat(tags, ", ")
)

tags = tag.sort(tag.parse("classics, historical, war, WWI, all-quiet-on-the-western-front-2"))
assert(
	"classics, historical, war, WWI, all-quiet-on-the-western-front-2" == table.concat(tags, ", "),
	table.concat(tags, ", ")
)

tags = tag.sort(tag.parse("fantasy, YA, romance, LGBT, Golden Poppy Book Award, raybearer-1"))
assert(
	"fantasy, YA, romance, LGBT, Golden Poppy Book Award, raybearer-1" == table.concat(tags, ", "),
	table.concat(tags, ", ")
)

tags = tag.sort(tag.parse("literary, historical, queer, LGBT, Andrew Carnegie Medal"))
assert("literary, historical, LGBT, queer, Andrew Carnegie Medal" == table.concat(tags, ", "), table.concat(tags, ", "))

tags = tag.sort(tag.parse("literary, contemporary, thriller, dark academia, (read after Lolita)"))
assert(
	"literary, thriller, contemporary, dark academia, (read after Lolita)" == table.concat(tags, ", "),
	table.concat(tags, ", ")
)

tags = tag.sort(
	tag.parse(
		"classics, horror, LGBT, queer, lesbian, mystery, Kate-Lee-경민-rec"
			.. ", [Audible](https://www.audible.com/pd/The-Girls-Audiobook/B0CN7N1G7L)"
	)
)
assert(
	"classics, horror, mystery, LGBT, queer, lesbian, Kate-Lee-경민-rec"
			.. ", [Audible](https://www.audible.com/pd/The-Girls-Audiobook/B0CN7N1G7L)"
		== table.concat(tags, ", "),
	table.concat(tags, ", ")
)

tags = tag.sort(
	tag.parse(
		"sci-fi, novella, dystopian, climate change, short stories, Le Guin Prize"
			.. ", [hoopla](https://www.hoopladigital.com/audiobook/arboreality-rebecca-campbell/16853273)"
	)
)
assert(
	"novella, short stories, sci-fi, dystopian, climate change, Le Guin Prize"
			.. ", [hoopla](https://www.hoopladigital.com/audiobook/arboreality-rebecca-campbell/16853273)"
		== table.concat(tags, ", "),
	table.concat(tags, ", ")
)

tags = tag.sort(
	tag.parse(
		"sci-fi, steampunk, adventure, fantasy, pirates"
			.. ", [Spotify](https://open.spotify.com/show/0a2gkBFEodL7puPVt7Crbx)"
			.. ", [Audible](https://www.audible.com/pd/Retribution-Falls-Audiobook/B00BFF4L72)"
			.. ", Tori-Morrow-rec, Willow-rec"
			.. ", tales-of-the-ketty-jay-1"
	)
)
assert(
	"sci-fi, fantasy, adventure, steampunk, pirates, tales-of-the-ketty-jay-1, Tori-Morrow-rec, Willow-rec"
			.. ", [Spotify](https://open.spotify.com/show/0a2gkBFEodL7puPVt7Crbx)"
			.. ", [Audible](https://www.audible.com/pd/Retribution-Falls-Audiobook/B00BFF4L72)"
		== table.concat(tags, ", "),
	table.concat(tags, ", ")
)

tags = tag.sort(tag.parse("mystery, sci-fi, thriller, time travel, unread country"))
assert("mystery, sci-fi, thriller, time travel, unread country" == table.concat(tags, ", "), table.concat(tags, ", "))

tags = tag.sort(tag.parse("classics, reread, sci-fi, space opera, speculative, Nebula Award"))
assert(
	"classics, sci-fi, space opera, speculative, Nebula Award, reread" == table.concat(tags, ", "),
	table.concat(tags, ", ")
)

-- ownership always last

tags = tag.sort(
	tag.parse(
		"mystery, indigenous, mighty-muskrats-1, YA, [own]"
			.. ", [hoopla](https://www.hoopladigital.com/audiobook/the-case-of-windy-lake-michael-hutchinson/14047796)"
	)
)
assert(
	"mystery, YA, indigenous, mighty-muskrats-1"
			.. ", [hoopla](https://www.hoopladigital.com/audiobook/the-case-of-windy-lake-michael-hutchinson/14047796)"
			.. ", [own]"
		== table.concat(tags, ", ")
)
