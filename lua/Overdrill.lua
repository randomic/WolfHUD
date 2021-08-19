function isFirstWorldBank()
    return managers.job:current_level_id() == "red2"
end

function isLoud()
    return not managers.groupai:state():whisper_mode()
end

function isDeathWishOrDeathSentence()
    return Global.game_settings.difficulty == "overkill_290" or Global.game_settings.difficulty == "sm_wish"
end

if not _overdrillActivated then
    _overdrillActivated = true
    if Network:is_server() and isFirstWorldBank() and isLoud() and isDeathWishOrDeathSentence() then
        for _, script in pairs(managers.mission:scripts()) do
            for id, element in pairs(script:elements()) do
                for _, trigger in pairs(element:values().trigger_list or {}) do
                    if trigger.notify_unit_sequence == "light_on" then
                        element:on_executed()
                        managers.chat:_receive_message(1, "Overdrill", "Ready to place the Overdrill", tweak_data.system_chat_color)
                        RefreshTest()
                    end
                end
            end
        end
    else
        managers.chat:_receive_message(1, "Overdrill", "Conditions are not met!", Color.yellow)
        managers.chat:_receive_message(1, "Requirements", "Hosting a lobby, Deathwish Loud", Color.yellow)
    end
else
    managers.chat:_receive_message(1, "Overdrill", "Already activated", Color.red)
    RefreshTest()
end
