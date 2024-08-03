extends Node

const exampleEvents = ["Aloha", "Apfel", "Birne", "Kiwi", "Melone", "Erdbeere", "Banane", "Gurke", "Kirsche"]
const exampleDescriptions = ["Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr"]

func get_random_events() -> Array[String]: # TODO: implement
	return [exampleEvents.pick_random(), exampleEvents.pick_random(), exampleEvents.pick_random()]

func get_event_description_from_name(eventName) -> String: # TODO: implement
	print("get desc for Event: ", eventName)
	return exampleDescriptions[0]
