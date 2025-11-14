obs = obslua

monitor_id = 0
trigger_scene = ""
already_opened = false


PROJECTOR_PROGRAM = 2   -- nilai default OBS untuk Program Projector

function open_projector_safe()
    if already_opened then return end

    obs.obs_frontend_open_projector(
        PROJECTOR_PROGRAM,   -- dipaksa ke program
        monitor_id,
        "",
        ""
    )

    already_opened = true
end

function handle_scene()
    if trigger_scene == "" then
        open_projector_safe()
        return
    end

    local cur = obs.obs_frontend_get_current_scene()
    local name = obs.obs_source_get_name(cur)

    if name == trigger_scene then
        open_projector_safe()
    end

    obs.obs_source_release(cur)
end

function on_event(event)
    if event == obs.OBS_FRONTEND_EVENT_FINISHED_LOADING then
        open_projector_safe()
    elseif event == obs.OBS_FRONTEND_EVENT_SCENE_CHANGED then
        handle_scene()
    end
end

function script_properties()
    local p = obs.obs_properties_create()
    obs.obs_properties_add_int(p, "monitor_id", "Monitor ID", 0, 10, 1)
    obs.obs_properties_add_text(p, "trigger_scene", "Trigger Scene", obs.OBS_TEXT_DEFAULT)
    return p
end

function script_update(s)
    monitor_id = obs.obs_data_get_int(s, "monitor_id")
    trigger_scene = obs.obs_data_get_string(s, "trigger_scene")
    already_opened = false
end

function script_load(s)
    obs.obs_frontend_add_event_callback(on_event)
end
