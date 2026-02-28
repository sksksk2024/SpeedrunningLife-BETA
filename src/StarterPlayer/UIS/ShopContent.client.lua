local ts = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")
local MarketPlaceService = game:GetService("MarketplaceService")
local Passes = require(RS.Modules.Constants).Passes
local DevProducts = require(RS.Modules.Constants).DevProducts
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local gui = script.Parent
local shop = gui.Vignette
local buttonClosed = gui.ShopClosed
local buttonOpened = gui.Vignette.ShopOpened

local shopItems = shop.Shop.ScrollingFrame
local mainProduct = shopItems.MainProduct.MainProductBtn
--local secProduct1 = shopItems.Row1.secProduct1.secProductBtn1
local secProduct2 = shopItems.Row1.secProduct2.secProductBtn2
local secProduct3 = shopItems.Row2.secProduct3.secProductBtn3
local secProduct4 = shopItems.Row2.secProduct4.secProductBtn4

-- Get the products by the buttons
local mainProductFrame = mainProduct.Parent
--local secProduct1Frame = secProduct1.Parent
local secProduct2Frame = secProduct2.Parent
local secProduct3Frame = secProduct3.Parent
local secProduct4Frame = secProduct4.Parent

-- store the values from udim2 with new value
local normalShopSize = UDim2.new(0, 100, 0, 100)
local hoveredShopSize = UDim2.new(0, 90, 0, 90)

-- store the values from udim2 with new value
local mainProductNormalSize = UDim2.new(0.95, 0,0.97, 0)
local mainProductHoveredSize = UDim2.new(0.92, 0, 0.94, 0)

local secProduct1NormalSize = UDim2.new(0.485, 0,1, 0)
local secProduct2NormalSize = UDim2.new(0.485, 0,1, 0)
local secProduct3NormalSize = UDim2.new(0.485, 0,1, 0)
local secProduct4NormalSize = UDim2.new(0.485, 0,1, 0)
local secProduct1HoveredSize = UDim2.new(0.482, 0, 0.98, 0)

-- Utility functions for the prompt
local function promptPass(id)
	MarketPlaceService:PromptGamePassPurchase(player, id)
end

local function promptProduct(id)
	MarketPlaceService:PromptProductPurchase(player, id)
end

buttonClosed.MouseButton1Click:Connect(function()
	buttonClosed.Visible = false
	shop.Visible = true
end)

buttonOpened.MouseButton1Click:Connect(function()
	buttonClosed.Visible = true
	shop.Visible = false
end)

-- on hover, animate it to be bigger
local animBtnShopClosedNormalSize = ts:Create(buttonClosed, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = normalShopSize})
local animBtnShopClosedHoveredSize = ts:Create(buttonClosed, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = hoveredShopSize})

local animBtnShopOpenedNormalSize = ts:Create(buttonOpened, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = normalShopSize})
local animBtnShopOpenedHoveredSize = ts:Create(buttonOpened, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = hoveredShopSize})

local animFrameMainNormalSize = ts:Create(mainProductFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = mainProductNormalSize})
--local animFrameSec1NormalSize = ts:Create(secProduct1Frame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = secProduct1NormalSize})
local animFrameSec2NormalSize = ts:Create(secProduct2Frame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = secProduct1NormalSize})
local animFrameSec3NormalSize = ts:Create(secProduct3Frame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = secProduct1NormalSize})
local animFrameSec4NormalSize = ts:Create(secProduct4Frame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = secProduct1NormalSize})

local animFrameMainHoveredSize = ts:Create(mainProductFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = mainProductHoveredSize})
--local animFrameSec1HoveredSize = ts:Create(secProduct1Frame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = secProduct1HoveredSize})
local animFrameSec2HoveredSize = ts:Create(secProduct2Frame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = secProduct1HoveredSize})
local animFrameSec3HoveredSize = ts:Create(secProduct3Frame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = secProduct1HoveredSize})
local animFrameSec4HoveredSize = ts:Create(secProduct4Frame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = secProduct1HoveredSize})


buttonClosed.MouseEnter:Connect(function()
	animBtnShopClosedHoveredSize:Play()
end)

buttonOpened.MouseEnter:Connect(function()
	animBtnShopOpenedHoveredSize:Play()
end)

mainProduct.MouseEnter:Connect(function()
	-- animate the product frame to be hovered size
	animFrameMainHoveredSize:Play()
end)

--secProduct1.MouseEnter:Connect(function()
--	-- animate the product frame to be hovered size
--	animFrameSec1HoveredSize:Play()
--end)

secProduct2.MouseEnter:Connect(function()
	-- animate the product frame to be hovered size
	animFrameSec2HoveredSize:Play()
end)

secProduct3.MouseEnter:Connect(function()
	-- animate the product frame to be hovered size
	animFrameSec3HoveredSize:Play()
end)

secProduct4.MouseEnter:Connect(function()
	-- animate the product frame to be hovered size
	animFrameSec4HoveredSize:Play()
end)


-- when the mouse leaves, animate it back to normal
buttonClosed.MouseLeave:Connect(function()
	animBtnShopClosedNormalSize:Play()
end)

buttonOpened.MouseLeave:Connect(function()
	animBtnShopOpenedNormalSize:Play()
end)

-- sa rezolv cu level-ul si unde poate intra caracter-ul
-- user input si pentru telefoane pentru parkour, si bullies, intrare - customizare de asemenea!!!

mainProduct.MouseLeave:Connect(function()
	-- animate the product frame to be normal size
	animFrameMainNormalSize:Play()
end)

--secProduct1.MouseLeave:Connect(function()
--	-- animate the product frame to be normal size
--	animFrameSec1NormalSize:Play()
--end)

secProduct2.MouseLeave:Connect(function()
	-- animate the product frame to be normal size
	animFrameSec2NormalSize:Play()
end)

secProduct3.MouseLeave:Connect(function()
	-- animate the product frame to be normal size
	animFrameSec3NormalSize:Play()
end)

secProduct4.MouseLeave:Connect(function()
	-- animate the product frame to be normal size
	animFrameSec4NormalSize:Play()
end)

-- Buying passes
mainProduct.MouseButton1Click:Connect(function()
	promptPass(Passes.DoubleSpeed)
end)

--secProduct1.MouseButton1Click:Connect(function()
--	promptPass(Passes.Teleportation)
--end)

-- Buying dev products
secProduct2.MouseButton1Click:Connect(function()
	promptProduct(DevProducts.RechargeMap)
end)

secProduct3.MouseButton1Click:Connect(function()
	promptProduct(DevProducts.RechargeResources)
end)

secProduct4.MouseButton1Click:Connect(function()
	promptProduct(DevProducts.LevelUp)
end)