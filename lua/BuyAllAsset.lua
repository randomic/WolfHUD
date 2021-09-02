if string.lower(RequiredScript) == "lib/managers/missionassetsmanager" then
	function MissionAssetsManager:asset_is_buyable(asset)
		return self:asset_is_locked(asset) and (Network:is_server() and asset.can_unlock or Network:is_client() and self:get_asset_can_unlock_by_id(asset.id))
	end

	function MissionAssetsManager:asset_is_locked(asset)
		return asset.show and not asset.unlocked
	end

	function MissionAssetsManager:has_buyable_assets()
		local level_id = managers.job:current_level_id()
		if self:is_unlock_asset_allowed() and not tweak_data.preplanning or not tweak_data.preplanning.locations or not tweak_data.preplanning.locations[level_id] then
			local asset_costs = self:get_total_assets_costs()
			if asset_costs > 0 then
				return true
			end
		end
		return false
	end

	function MissionAssetsManager:get_total_assets_costs()
		local total_costs = 0
		for _, asset in ipairs(self._global.assets) do
			if self:asset_is_buyable(asset) then
				total_costs = total_costs + (asset.id and managers.money:get_mission_asset_cost_by_id(asset.id) or 0)
			end
		end
		return total_costs
	end
elseif string.lower(RequiredScript) == "lib/managers/menu/missionbriefinggui" then
	local create_assets_original = AssetsItem.create_assets
	local unlock_asset_by_id_original = AssetsItem.unlock_asset_by_id
	local confirm_pressed_original = AssetsItem.confirm_pressed
	local mouse_moved_original = AssetsItem.mouse_moved

	function AssetsItem:create_assets(...)
		create_assets_original(self, ...)
		self:update_buy_all_button()
	end

	function AssetsItem:unlock_asset_by_id(...)
		unlock_asset_by_id_original(self, ...)
		self:update_buy_all_button()
	end

	function AssetsItem:confirm_pressed(...)
		local result = confirm_pressed_original(self, ...)

		self:update_buy_all_button()

		return result
	end

	function AssetsItem:mouse_moved(x, y, ...)

		if alive(self.buy_all_button) and self.buy_all_button:inside(x, y) then
			if managers.assets:has_buyable_assets() and not self.buy_all_button_highlighted then
				self.buy_all_button_highlighted = true
				
				self:update_buy_all_button(true)
				managers.menu_component:post_event("highlight")
			end

			self:check_deselect_item()

			return false, true
		elseif self.buy_all_button_highlighted then
			self.buy_all_button_highlighted = false

			self:update_buy_all_button(true)
		end

		return mouse_moved_original(self, x, y, ...)
	end

	function AssetsItem:update_buy_all_button(colors_only)
		if alive(self.buy_all_button) then
			if managers.assets:has_buyable_assets() then
				if self:can_afford_all_assets() then
					self.buy_all_button:set_color(self.buy_all_button_highlighted and tweak_data.screen_colors.button_stage_2 or tweak_data.screen_colors.button_stage_3)
				else
					self.buy_all_button:set_color(tweak_data.screen_colors.pro_color)
				end
			else
				self.buy_all_button:set_color(tweak_data.screen_color_grey)
			end
			if not colors_only then
				local asset_costs = managers.assets:get_total_assets_costs()
				local text = string.format("%s (%s)", managers.localization:to_upper_text("wolfhud_buy_all_assets"), managers.experience:cash_string(asset_costs))
				self.buy_all_button:set_text(text)
				local _, _, w, _ = self.buy_all_button:text_rect()
				self.buy_all_button:set_w(math.ceil(w))
				if managers.menu:is_pc_controller() then
					self.buy_all_button:set_right(self._panel:w() - 5)
				else
					self.buy_all_button:set_left(5)
				end
			end
		end
	end

	function AssetsItem:can_afford_all_assets()
		return (managers.assets:get_total_assets_costs() <= managers.money:total())
	end
end
