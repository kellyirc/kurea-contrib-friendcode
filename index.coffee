module.exports = (Module) ->
	
	class FriendCodeModule extends Module
		shortName: "FriendCode"
		helpText:
			default: "Use friendcode *code* to register your friend code. Use friendcode *nick* to see a registered user's friend code."
		usage:
			default: "friendcode *"
		friendCodeRegex: "\\b([0-9]{4}[-\\s]?){2}([0-9]{4})\\b"
	
		constructor: (moduleManager) ->
			super(moduleManager)

			@getApi().getFriendCode = (origin, callback) =>
				@getUserData origin, "friendCode", (data) =>
					callback?(data)


			@registerApi()

			@addRoute "friendcode *", (origin, route) =>
				value = @reformatFriendCode route.splats[0]
				if value.match @friendCodeRegex
					@setUserData origin, "friendCode", value, =>
						@getUserData origin, "friendCode", (data) =>
							@reply origin, "Your friend code is now #{data}"
				else
					origin.user = value # pretend we called as the user we searched for
					@getUserData origin, "friendCode", (data) =>
						if data?
							@reply origin, "#{value}'s friend code is #{data}"
						else
							@reply origin, "#{value}'s friend code is not stored!"	

			@addRoute "friendcode", (origin, route) =>
				console.log origin.bot.config.server, @shortName, origin.user
				@getUserData origin, "friendCode", (data) =>
					if data?
						@reply origin, "#{origin.user}'s friend code is #{data}"
					else
						@reply origin, "#{origin.user}'s friend code is not stored!"
				

		reformatFriendCode: (unformattedCode) ->
			StringSplice = (stringToSplice, index, charsToRemove, stringToInsert) ->
				return stringToSplice.slice(0, index) + stringToInsert + stringToSplice.slice(index + Math.abs(charsToRemove))


			friendCodeRegex = new RegExp("\\b([0-9]{4}){3}\\b")
			friendCodeRegexWithSpaces = new RegExp("\\b([0-9]{4}\\s){2}([0-9]{4}){1}\\b")


			formattedCode = unformattedCode
			if unformattedCode.match(friendCodeRegex)
				dashesToInsert = 2
				(formattedCode = StringSplice(formattedCode, (4 * (x + 1) + x), 0, "-")) for x in [0..(dashesToInsert-1)]
			else if unformattedCode.match(friendCodeRegexWithSpaces)
				formattedCode = formattedCode.replace(/\s/g, '-')
			return formattedCode

		
	FriendCodeModule