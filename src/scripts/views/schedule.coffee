import Marionette from 'backbone.marionette'
import template from 'templates/schedule'
import itemTemplate from 'templates/schedule/item'

import RequestUtils from 'lib/request'

MAX_SLOTS = 6

class ScheduleItemView extends Marionette.View
	template: itemTemplate
	className: 'list-group-item scheduleItem'

	triggers:
		'click .delete': 'delete'

	initialize: ->
		# console.log 'Initializing Schedule Item View'

export default class ScheduleView extends Marionette.CollectionView
	template: template
	className: 'schedule'

	childView: ScheduleItemView
	childViewContainer: '.scheduleContainer'

	ui:
		'addBtn': '#addBtn'

	events:
		'click @ui.addBtn': 'addItem'
	childViewEvents:
		'delete': 'handleDeleteChild'

	initialize: ->
		console.log 'Initializing Schedule View'

		@collection = new Backbone.Collection
		@collection.viewComparator = 'time'

		@collection.on 'add remove', => @updateAddBtnVisibility()

		@updateScheduleData()

	onRender: ->
		@updateAddBtnVisibility()

	updateScheduleData: (scheduleDetails)=>
		unless scheduleDetails?
			try
				scheduleDetails = await RequestUtils.getSchedule()
			catch err
				console.error 'Error fetching schedule:', err
		@collection.update scheduleDetails

	updateAddBtnVisibility: ->
		if @collection.length < MAX_SLOTS
			@ui.addBtn.show()
		else
			@ui.addBtn.hide()

	addItem: ->
		unless @collection.length >=  MAX_SLOTS
			console.log 'Adding item to schedule'
			@collection.add new Backbone.Model
				time: '12:00'
				qty: 1

	handleDeleteChild: (cv)->
		console.log 'Removing child from collection'
		@collection.remove cv.model