entFactory = {}
entFactory.recipes = {}
--local recipe = {}

function entFactory.update(dt)
	entFactory.processRecipes()
end

-- Add a recipe to the recipe list
function entFactory.addRecipe(entityName, amount, spawnInterval, spawnArea)
	if ents.isRegisteredEntity(entityName) then
		if spawnInterval > 0 then
			if entFactory.validateSpawnArea(spawnArea) then
				if amount > 0 or amount == -1 then
					-- amount == -1 is a special case: unlimited enemies: use reset to stop the factory			
					entFactory.createRecipe(entityName, amount, spawnInterval, spawnArea)
					--print("Added recipe: entity[" .. entityName .. "] amount[" .. amount .. "] interval[" .. spawnInterval .. "] area.x[" .. spawnArea.x .. "] area.y[" .. spawnArea.y .. "] area.w[" .. spawnArea.w .. "] area.h[" .. spawnArea.h .. "]")
				else
					print("Error: No amount specified for recipe!")
				end
			else
				print("Error: Spawn area incorrectly specified!")
			end
		else
			print("Error: Invalid spawninterval specified!")
		end
	else
		print("Error: Entity not registered!")
	end
end

-- Create recipe
function entFactory.createRecipe(entityName, amount, spawnInterval, spawnArea)
	local recipe = {entity=entityName, amount=amount, spawnInterval=spawnInterval, spawnCountDown=spawnInterval, spawnArea=spawnArea};
	table.insert(entFactory.recipes, recipe)
end

-- Remove a recipe from the recipe list
function entFactory.delRecipe(recipeId)
	if recipeId >= #entFactory.recipes and recipeId <= #entFactory.recipes then
		table.remove(entFactory.recipes, recipeId)
		--print("delete recipe from list [" .. recipeId .. "]")
	end
end

-- Reset the entityfactory
function entFactory.reset()
	entFactory.recipes = {}
end

-- Check if spawnArea is valid
function entFactory.validateSpawnArea(spawnArea)
	return spawnArea.x >= 0 and spawnArea.y >= 0 and spawnArea.w <= love.graphics.getWidth() and spawnArea.h <= love.graphics.getHeight();
end

-- Process recipes
function entFactory.processRecipes()
	local delRecipeList = {}
	if #entFactory.recipes > 0 then
		for i,recipe in pairs(entFactory.recipes) do
			if recipe.spawnCountDown == 1 then
				if recipe.amount == -1 then
					-- Special case: unlimited enemies: use reset to stop the factory
					entFactory.processRecipe(recipe)
				elseif recipe.amount > 0 then
					entFactory.processRecipe(recipe)
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

function entFactory.processRecipe(recipe)
	-- Randomize the x,y position within the spawnarea
	local x,y = entFactory.randCoord(recipe.spawnArea.x, recipe.spawnArea.y, recipe.spawnArea.x + recipe.spawnArea.w, recipe.spawnArea.y + recipe.spawnArea.h)
	-- Spawn entity
	ents.Create(recipe.entity, x, y)
	recipe.spawnArea.x = recipe.spawnArea.x + 25
	--print("create entity [".. recipe.entity .. "] [" .. recipe.amount .. "] [".. recipe.spawnArea.x .. "] [".. recipe.spawnArea.y .. "]")
	if recipe.amount ~= -1 then
		-- Decrease amount
		recipe.amount = recipe.amount - 1
	else
		-- Special case: unlimited enemies
	end
	--print("  recipe.amount [" .. recipe.amount .. "]")
	-- Reset interval
	recipe.spawnCountDown = recipe.spawnInterval
	--print("  reset countdown")
end

-- Coordinate randomizer
function entFactory.randCoord(x1, y1, x2, y2)
	local x = math.random(x1, x2)
	local y = math.random(y1, y2)
	return x,y;
end
