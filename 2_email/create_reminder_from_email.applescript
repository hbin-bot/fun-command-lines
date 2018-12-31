# Set this according to your email account names and Reminder's lists
set WorkAccountName to "work@example.com"
#set WorkRemindersList to "Work"
set PersonalAccountName to "personal@example.com"
#set PersonalRemindersList to "Personal"

# On my machine 5 is the Purple flag, which is the color I would like to use for mails flagged as Reminder
set FlagIndex to 4

tell application "Mail"

	set theSelection to selection
	# do nothing if no email is selected in Mail
	try
	set theMessage to item 1 of theSelection
	on error
	return
	end try

	set theSubject to theMessage's subject
	# Make sure reminder doesn't already exist so we don't create duplicates
	tell application "Reminders"

		set theNeedlesName to name of reminders whose name is theSubject and completed is false
		if theNeedlesName is not {} then
		# make sure dialog is in focus when called as a service
		# without the below, Mail would be the active application
		tell me
		activate
		end tell
		set theButton to button returned of (display dialog "The selected email matches an existing reminder: " & theNeedlesName & ". Would you like to mark the reminder as complete and clear any remaining flags of this message?" with title "Create Reminder from E-Mail" buttons {"Mark complete", "Cancel"} default button 1)

		if theButton is "Mark complete" then
		tell application "Mail"
		# unflag email/message
		set flag index of theMessage to -1
		end tell

		# find correct reminder based on subject and mark as complete
		set theNeedle to last reminder whose name is theSubject and completed is false
		set completed of theNeedle to true
		return
		else if the_button is "Cancel" then
		return
		end if

		end if
	end tell

	# present user with a list of follow-up times (in minutes)
	(choose from list {"Today", "Tomorrow", "End of Week", "Beginning of next Week", "1 Week", "Backlogs"} default items "Today" OK button name "Create" with prompt "Set follow-up time" with title "Create Reminder from E-Mail")

	set reminderDate to result as rich text

	# Exit if user clicks Cancel
	if reminderDate is "false" then return

	if reminderDate = "Today" then
		# set time to 1h after the creation
		set remindMeDate to current date
		set t to (time of (current date))
		set time of remindMeDate to t + 60 * 60 * 1

	else if reminderDate = "Tomorrow" then
		# add 1 day and set time to 9h into the day = 9am
		set remindMeDate to (current date) + 1 * days
		set time of remindMeDate to 60 * 60 * 11

	else if reminderDate = "End of Week" then
		# end of week means Friday in terms of reminders
		# get the current day of the week
		set curWeekDay to weekday of (current date) as string
		
		if curWeekDay = "Monday" then
			set remindMeDate to (current date) + 4 * days
		else if curWeekDay = "Tuesday" then
			set remindMeDate to (current date) + 3 * days
		else if curWeekDay = "Wednesday" then
			set remindMeDate to (current date) + 2 * days
		else if curWeekDay = "Thursday" then
			set remindMeDate to (current date) + 1 * days
		# if it's Friday I'll set the reminder for Monday next week
		else if curWeekDay = "Friday" then
			set remindMeDate to (current date) + 3 * days
		end if

		set time of remindMeDate to 60 * 60 * 11

	else if reminderDate = "Beginning of next Week" then
		# begining of next week means Monday in terms of reminders
		# get the current day of the week
		set curWeekDay to weekday of (current date) as string
		
		if curWeekDay = "Monday" then
			set remindMeDate to (current date) + 7 * days
		else if curWeekDay = "Tuesday" then
			set remindMeDate to (current date) + 6 * days
		else if curWeekDay = "Wednesday" then
			set remindMeDate to (current date) + 5 * days
		else if curWeekDay = "Thursday" then
			set remindMeDate to (current date) + 4 * days
		else if curWeekDay = "Friday" then
			set remindMeDate to (current date) + 3 * days
		else if curWeekDay = "Saturday" then
			set remindMeDate to (current date) + 2 * days
		else if curWeekDay = "Sunday" then
			set remindMeDate to (current date) + 1 * days
		end if

		set time of remindMeDate to 60 * 60 * 11
	else if reminderDate = "1 Week" then
		set remindMeDate to (current date) + 10080 * minutes
	else if reminderDate = "Backlogs" then
		set remindMeDate to (current date) + 43200 * minutes
	end if

	# Flag selected email/message in Mail
	set flag index of theMessage to FlagIndex

	# Get the unique identifier (ID) of selected email/message
	set theOrigMessageId to theMessage's message id

	#we need to encode % with %25 because otherwise the URL will be screwed up in Reminders and you won't be able to just click on it to open the linked message in Mail
	set theUrl to {"message:%3C" & my replaceText(theOrigMessageId, "%", "%25") & "%3E"}

	# determine correct Reminder's list based on account the email/message is in

	if name of account of mailbox of theMessage is WorkAccountName then
		# present user with a list of Reminders List
		(choose from list {"Active Tasks", "Blocked", "Backlogs"} default items "Active Tasks" OK button name "Create" with prompt "Select the Reminders List" with title "Create Reminder from E-Mail")

		set RemindersList to result as rich text
	else if name of account of mailbox of theMessage is PersonalAccountName then
		set RemindersList to "Personal"
		# set RemindersList to PersonalRemindersList
	else
		#default list name in Reminders
		set RemindersList to "Active Tasks"
	end if

end tell

tell application "Reminders"

	tell list RemindersList
	# create new reminder with proper due date, subject name and the URL linking to the email in Mail
	make new reminder with properties {name:theSubject, remind me date:remindMeDate, body:theUrl}

	end tell

end tell

# string replace function
# used to replace % with %25
on replaceText(subject, find, replace)
	set prevTIDs to text item delimiters of AppleScript
	set text item delimiters of AppleScript to find
	set subject to text items of subject

	set text item delimiters of AppleScript to replace
	set subject to "" & subject
	set text item delimiters of AppleScript to prevTIDs

	return subject
end replaceText