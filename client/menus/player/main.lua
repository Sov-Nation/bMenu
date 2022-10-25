--#region Variables

local noClipEnabled = false
local followCamMode = true
local currentScalefrom = -1
local movingSpeed = 0
local movingSpeeds = {
    [0] = 'Very Slow',
    [1] = 'Slow',
    [2] = 'Normal',
    [3] = 'Fast',
    [4] = 'Very Fast',
    [5] = 'Extremely Fast',
    [6] = 'Staggeringly Fast',
    [7] = 'Max Speed'
}

--#endregion Variables

--#region Menu Registration

lib.registerMenu({
    id = 'berkie_menu_player_related_options',
    title = 'Player Related Options',
    position = 'top-right',
    onClose = function(keyPressed)
        CloseMenu(false, keyPressed, 'berkie_menu_main')
    end,
    onSelected = function(selected)
        MenuIndexes['berkie_menu_player_related_options'] = selected
    end,
    options = {
        {label = 'Player Options', description = 'Common player options can be accessed here', args = 'berkie_menu_player_options'},
        {label = 'Weapon Options', description = 'Add/remove weapons, modify weapons and set ammo options', args = 'berkie_menu_player_weapon_options'},
        {label = 'Toggle Noclip', description = 'Toggle NoClip on or off', args = 'toggle_noclip', close = false}
    }
}, function(_, _, args)
    if args == 'toggle_noclip' then
        noClipEnabled = not noClipEnabled
        if noClipEnabled then
            currentScalefrom = RequestScaleformMovie('INSTRUCTIONAL_BUTTONS')
            while not HasScaleformMovieLoaded(currentScalefrom) do
                Wait(500)
            end
            DrawScaleformMovieFullscreen(currentScalefrom, 255, 255, 255, 0, 0)
        else
            currentScalefrom = -1
            local noclipEntity = cache.vehicle or cache.ped
            FreezeEntityPosition(noclipEntity, false)
            SetEntityInvincible(noclipEntity, false)
            SetEntityCollision(noclipEntity, true, true)

            SetEntityVisible(noclipEntity, true, false)
            SetLocalPlayerVisibleLocally(true)

            ResetEntityAlpha(noclipEntity)

            SetEveryoneIgnorePlayer(LocalPlayerId, false)
            SetPoliceIgnorePlayer(LocalPlayerId, false)
        end
    else
        lib.showMenu(args, MenuIndexes[args])
    end
end)

--#endregion Menu Registration

--#region Threads

CreateThread(function()
    while true do
        if noClipEnabled then
            if not IsHudHidden() and currentScalefrom ~= -1 then
                BeginScaleformMovieMethod(currentScalefrom, 'CLEAR_ALL')
                EndScaleformMovieMethod()

                BeginScaleformMovieMethod(currentScalefrom, 'SET_DATA_SLOT')
                ScaleformMovieMethodAddParamInt(0)
                ScaleformMovieMethodAddParamTextureNameString('~INPUT_STRING~')
                ScaleformMovieMethodAddParamTextureNameString(('Change Speed: %s'):format(movingSpeeds[movingSpeed]))
                EndScaleformMovieMethod()

                BeginScaleformMovieMethod(currentScalefrom, 'SET_DATA_SLOT')
                ScaleformMovieMethodAddParamInt(1)
                ScaleformMovieMethodAddParamTextureNameString('~INPUT_MOVE_LR~')
                ScaleformMovieMethodAddParamTextureNameString('Turn Left/Right')
                EndScaleformMovieMethod()

                BeginScaleformMovieMethod(currentScalefrom, 'SET_DATA_SLOT')
                ScaleformMovieMethodAddParamInt(2)
                ScaleformMovieMethodAddParamTextureNameString('~INPUT_MOVE_UD~')
                ScaleformMovieMethodAddParamTextureNameString('Move')
                EndScaleformMovieMethod()

                BeginScaleformMovieMethod(currentScalefrom, 'SET_DATA_SLOT')
                ScaleformMovieMethodAddParamInt(3)
                ScaleformMovieMethodAddParamTextureNameString('~INPUT_MULTIPLAYER_INFO~')
                ScaleformMovieMethodAddParamTextureNameString('Down')
                EndScaleformMovieMethod()

                BeginScaleformMovieMethod(currentScalefrom, 'SET_DATA_SLOT')
                ScaleformMovieMethodAddParamInt(4)
                ScaleformMovieMethodAddParamTextureNameString('~INPUT_COVER~')
                ScaleformMovieMethodAddParamTextureNameString('Up')
                EndScaleformMovieMethod()

                BeginScaleformMovieMethod(currentScalefrom, 'SET_DATA_SLOT')
                ScaleformMovieMethodAddParamInt(5)
                ScaleformMovieMethodAddParamTextureNameString('~INPUT_VEH_HEADLIGHT~')
                ScaleformMovieMethodAddParamTextureNameString('Cam Mode')
                EndScaleformMovieMethod()

                BeginScaleformMovieMethod(currentScalefrom, 'DRAW_INSTRUCTIONAL_BUTTONS')
                ScaleformMovieMethodAddParamInt(0)
                EndScaleformMovieMethod()

                DrawScaleformMovieFullscreen(currentScalefrom, 255, 255, 255, 255, 0)
            end

            local noclipEntity = cache.vehicle or cache.ped

            FreezeEntityPosition(noclipEntity, true)
            SetEntityInvincible(noclipEntity, true)

            DisableControlAction(0, 20, true)
            DisableControlAction(0, 30, true)
            DisableControlAction(0, 31, true)
            DisableControlAction(0, 32, true)
            DisableControlAction(0, 33, true)
            DisableControlAction(0, 34, true)
            DisableControlAction(0, 35, true)
            DisableControlAction(0, 44, true)
            DisableControlAction(0, 74, true)
            if cache.vehicle then
                DisableControlAction(0, 75, true)
                DisableControlAction(0, 85, true)
            end
            DisableControlAction(0, 266, true)
            DisableControlAction(0, 267, true)
            DisableControlAction(0, 268, true)
            DisableControlAction(0, 269, true)

            local yOff = 0.0
            local zOff = 0.0
            local currentHeading = GetEntityHeading(noclipEntity)

            if IsInputDisabled(2) and UpdateOnscreenKeyboard() ~= 0 and not IsPauseMenuActive() then
                if IsControlJustPressed(0, 21) then
                    movingSpeed += 1
                    if movingSpeed == 8 then
                        movingSpeed = 0
                    end
                end

                if IsDisabledControlPressed(0, 32) then
                    yOff = 0.5
                end

                if IsDisabledControlPressed(0, 33) then
                    yOff = -0.5
                end

                if not followCamMode and IsDisabledControlPressed(0, 34) then
                    currentHeading += 3
                end

                if not followCamMode and IsDisabledControlPressed(0, 35) then
                    currentHeading -= 3
                end

                if IsDisabledControlPressed(0, 44) then
                    zOff = 0.21
                end

                if IsDisabledControlPressed(0, 20) then
                    zOff = -0.21
                end

                if IsDisabledControlJustPressed(0, 74) then
                    followCamMode = not followCamMode
                end
            end

            local moveSpeed = movingSpeed

            if movingSpeed > 4 then
                moveSpeed *= 1.8
            end

            moveSpeed = moveSpeed / (1 / GetFrameTime()) * 60
            local newPos = GetOffsetFromEntityInWorldCoords(noclipEntity, 0.0, yOff * (moveSpeed + 0.3), zOff * (moveSpeed + 0.3))

            SetEntityVelocity(noclipEntity, 0.0, 0.0, 0.0)
            SetEntityRotation(noclipEntity, followCamMode and GetGameplayCamRelativePitch() or 0.0, 0.0, 0.0, 0, false)
            SetEntityHeading(noclipEntity, followCamMode and GetGameplayCamRelativeHeading() or currentHeading)
            SetEntityCollision(noclipEntity, false, false)
            SetEntityCoordsNoOffset(noclipEntity, newPos.x, newPos.y, newPos.z, true, true, true)

            SetEntityVisible(noclipEntity, false, false)
            SetLocalPlayerVisibleLocally(true)
            SetEntityAlpha(noclipEntity, 51, false)

            SetEveryoneIgnorePlayer(LocalPlayerId, true)
            SetPoliceIgnorePlayer(LocalPlayerId, true)
        end
        Wait(0)
    end
end)

--#endregion Threads