function isFirstWorldBank()
    return managers.job:current_level_id() == "red2"
end

function isLoud()
    return not managers.groupai:state():whisper_mode()
end

function isAtLeastDeathWish()
    return Global.game_settings.difficulty == "overkill_290" or Global.game_settings.difficulty == "sm_wish"
end

function activateOverdrill()
    for _, script in pairs(managers.mission:scripts()) do
        for id, element in pairs(script:elements()) do
            for _, trigger in pairs(element:values().trigger_list or {}) do
                if trigger.notify_unit_sequence == "light_on" then
                    element:on_executed()
                    return
                end
            end
        end
    end
end

if isFirstWorldBank() then
    if not _overdrillActivated then
        if Network:is_server() and isAtLeastDeathWish() and isLoud() then
            activateOverdrill()
            managers.chat:_receive_message(1, "Overdrill", "Ready to place the Overdrill", tweak_data.system_chat_color)
            _overdrillActivated = true
            RefreshTest()
        else
            managers.chat:_receive_message(1, "Overdrill", "Conditions are not met!", Color.yellow)
            managers.chat:_receive_message(1, "Requirements", "Host, Deathwish+, Loud", Color.yellow)
        end
    else
        managers.chat:_receive_message(1, "Overdrill", "Already activated", Color.red)
    end
end
