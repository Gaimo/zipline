local wait = wait()
local ziplines = {}
local currentZiplineCol
local thePlayerIsOnAZipline = false

function getAdjustedTime(distance, metersPerSeconds)
    return (distance / metersPerSeconds) * 1000
end

function playerLookToTarget(targetPos)
    local playerPosition = Vector3(getElementPosition(localPlayer))
    local rotation = findRotation(playerPosition.x, playerPosition.y, targetPos.x, targetPos.y)
    setElementRotation(localPlayer, 0, 0, rotation)
end

function isElementInsideColShape( theElement, theColShape )
    if not theColShape then return false end
    return isInsideColShape( theColShape, getElementPosition( theElement ) )
end

function createTempObject()
    local tempObject = createObject(1337, 0, 0, 0)
    local tempObjectPosition = Vector3(getElementPosition(tempObject))

    local startPosition = Vector3(getElementPosition(currentZiplineCol))
    local targetPosition = Vector3(getElementPosition(ziplines[currentZiplineCol]))

    local distance = getDistanceBetweenPoints3D(tempObjectPosition.x, tempObjectPosition.y, tempObjectPosition.z, targetPosition.x, targetPosition.y, targetPosition.z)
    local time = getAdjustedTime(distance, config.ziplineVelocity)

    setElementCollisionsEnabled( tempObject, false)
    setElementAlpha( tempObject, 0)
    setElementPosition( tempObject, startPosition.x, startPosition.y, startPosition.z)

    moveObject(tempObject, time, targetPosition.x, targetPosition.y, targetPosition.z)
    
    return tempObject, targetPosition
end

function movePlayer()    
    if thePlayerIsOnAZipline then return end -- Se o jogador já está em movimento numa zipline
    if isPedInVehicle( localPlayer ) then return end -- Se o jogador estiver em um carro
    if not isElementInsideColShape(localPlayer, currentZiplineCol) then return end -- Se o jogador não estiver dentro de uma ziplinecol
    
    thePlayerIsOnAZipline = true
    local tempObject, targetPosition = createTempObject()

    playerLookToTarget(targetPosition)
    setTimer(function()
        setElementFrozen(localPlayer, true)
        setPedAnimation(localPlayer, "CAMERA", "picstnd_take", -1, true, false, false)
    end, 100, 1)

    function movePlayer()
        local tempObjectPosition = Vector3(getElementPosition(tempObject))
        setElementPosition(localPlayer, tempObjectPosition.x, tempObjectPosition.y, tempObjectPosition.z, false)

        if wait(100) then
            local tempObjectPosition = Vector3(getElementPosition(tempObject))
            local distance = getDistanceBetweenPoints3D(tempObjectPosition.x, tempObjectPosition.y, tempObjectPosition.z, targetPosition.x, targetPosition.y, targetPosition.z)

            if (distance == 0) then
                removeEventHandler("onClientRender", root, movePlayer) 
                destroyElement(tempObject)
                thePlayerIsOnAZipline = false
                setElementFrozen(localPlayer, false)
                setPedAnimation(localPlayer)
            end
        end
    end
    addEventHandler("onClientRender", root, movePlayer)
end
bindKey("E", "down", movePlayer)

function setup()
    for i,v in ipairs(config.ziplines) do 
        local aCollision = createColSphere( v.a[1], v.a[2], v.a[3], config.ziplineColRadius )
        local bCollision = createColSphere( v.b[1], v.b[2], v.b[3], config.ziplineColRadius )   

        ziplines[aCollision] = bCollision
        ziplines[bCollision] = aCollision
    end
end
setup()

addEventHandler("onClientElementColShapeHit", root, function(collision, matchingDimension)
    if matchingDimension then
        currentZiplineCol = collision
    end
end)

-- Render lines
addEventHandler("onClientRender", root, function()
    local skip = false 

    for i,v in pairs(ziplines) do
        if skip then 

            local startPos = Vector3(getElementPosition(i))
            local endPos = Vector3(getElementPosition(v))
            dxDrawLine3D(startPos.x, startPos.y, startPos.z + config.ziplineOffsetZ, endPos.x, endPos.y, endPos.z + config.ziplineOffsetZ, tocolor(0,0,0), 1)
        end
        
        skip = not skip
    end
end)