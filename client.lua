local wait = wait()
local ziplines = {}
local currentZiplineCol
local thePlayerIsOnAZipline = false

function getAdjustedTime(distance, metersPerSeconds)
    return (distance / metersPerSeconds) * 1000
end

function setup()
    for i,v in ipairs(config.ziplines) do 
        local aCollision = createColSphere( v.a[1], v.a[2], v.a[3], config.ziplineColRadius )
        local bCollision = createColSphere( v.b[1], v.b[2], v.b[3], config.ziplineColRadius )

        ziplines[aCollision] = bCollision
        ziplines[bCollision] = aCollision
    end
end
setup()


function isElementInsideColShape( theElement, theColShape )
    return isInsideColShape( theColShape, getElementPosition( theElement ) )
end


function movePlayer()
    -- Não permite continuar a função se:

    -- Se o jogador não estiver dentro de uma ziplinecol
    if not isElementInsideColShape(localPlayer, currentZiplineCol) then return end
    -- Se o jogador já está em movimento numa zipline
    if thePlayerIsOnAZipline then return end 
    -- Se o jogador estiver em um carro
    if isPedInVehicle( localPlayer ) then return end

    thePlayerIsOnAZipline = true
    
    local tempObject = createObject(1337, 0, 0, 0)
    local startPosition = Vector3(getElementPosition(currentZiplineCol))
    local targetPosition = Vector3(getElementPosition(ziplines[currentZiplineCol]))


    setElementCollisionsEnabled( tempObject, false)
    setElementAlpha( tempObject, 0)
    setElementPosition( tempObject, startPosition.x, startPosition.y, startPosition.z)

    local tempObjectPosition = Vector3(getElementPosition(tempObject))
    local distance = getDistanceBetweenPoints3D(tempObjectPosition.x, tempObjectPosition.y, tempObjectPosition.z, targetPosition.x, targetPosition.y, targetPosition.z)

    moveObject(tempObject, getAdjustedTime(distance, 10), targetPosition.x, targetPosition.y, targetPosition.z)
    
    function movePlayer()
        setElementPosition(localPlayer, getElementPosition(tempObject))

        if wait(100) then
            local tempObjectPosition = Vector3(getElementPosition(tempObject))
            local distance = getDistanceBetweenPoints3D(tempObjectPosition.x, tempObjectPosition.y, tempObjectPosition.z, targetPosition.x, targetPosition.y, targetPosition.z)

            if (distance == 0) then
                removeEventHandler("onClientRender", root, movePlayer) 
                destroyElement(tempObject)
                thePlayerIsOnAZipline = false
                print("Chegamos ao destino!")
            end
        end
    end
    addEventHandler("onClientRender", root, movePlayer)
end
bindKey("E", "down", movePlayer)

addEventHandler("onClientElementColShapeHit", root, function(collision, matchingDimension)
    if matchingDimension then
        currentZiplineCol = collision
    end
end)

