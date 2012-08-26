entFactory = {}
entFactory.recipes = {}
local recipe = {}

function entFactory.update(dt)
	entFactory.processRecipes()
end

-- Add a recipe to the recipe list
function entFactory.addRecipe(entityName, amount, spawnInterval, spawnArea)
	if ents.isRegisteredEntity(entityName) then
		if amount > 0 then
			if spawnInterval > 0 then
				if spawnArea.x >= 0 and spawnArea.y >= 0 and spawnArea.w <= love.graphics.getWidth() and spawnArea.h <= love.graphics.getHeight() then
					recipe = {entity=entityName, amount=amount, spawnInterval=spawnInterval, spawnCountDown=spawnInterval, spawnArea=spawnArea}
					table.insert(entFactory.recipes, recipe)
					--print("Added recipe: entity[" .. entityName .. "] amount[" .. amount .. "] interval[" .. spawnInterval .. "] area.x[" .. spawnArea.x .. "] area.y[" .. spawnArea.y .. "] area.w[" .. spawnArea.w .. "] area.h[" .. spawnArea.h .. "]")
				else
					print("Error: Spawn area incorrectly specified!")
				end
			else
				print("Error: Invalid spawninterval specified!")
			end
		else
			print("Error: No amount specified for recipe!")
		end
	else
		print("Error: Entity not registered!")
	end
end

-- Remove a recipe from the recipe list
function entFactory.delRecipe(recipeId)
	if recipeId >= #recipe and recipeId <= #recipe then
		table.remove(entFactory.recipes, recipeId)
		--print("delete recipe from list [" .. recipeId .. "]")
	end
end

-- Process recipes
function entFactory.processRecipes()
	local delRecipeList = {}
	if #entFactory.recipes > 0 then
		for i,recipe in pairs(entFactory.recipes) do
			if recipe.spawnCountDown == 1 then
				if recipe.amount > 0 then
					-- Spawn entity
					ents.Create(recipe.entity, recipe.spawnArea.x, recipe.spawnArea.y + i*50)
					recipe.spawnArea.x = recipe.spawnArea.x + 25
					--print("create entity [".. recipe.entity .. "] [" .. recipe.amount .. "] [".. recipe.spawnArea.x .. "] [".. recipe.spawnArea.y .. "]")
					-- Decrease amount
					recipe.amount = recipe.amount - 1
					--print("  recipe.amount [" .. recipe.amount .. "]")
					-- Reset interval
					recipe.spawnCountDown = recipe.spawnInterval
					--print("  reset countdown")
				else
					-- Recipe complete, delete from the list
					table.insert(delRecipeList, i)
				end
			else
				-- Decrease countDown
				recipe.spawnCountDown = recipe.spawnCountDown - 1
				--print ("Decrease countdown recipe [" .. i .. "] [ " ..recipe.amount .. " ] [" .. recipe.spawnCountDown .. "]")
			end
		end
		
		-- remove completed recipes
		if #delRecipeList > 0 then
			for i,v in ipairs(delRecipeList) do
				entFactory.delRecipe(v)
			end
		end
	end
end
