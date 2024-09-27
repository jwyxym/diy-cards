--黑暗仙精们
xpcall(function() dofile("expansions/script/c16199990.lua") end,function() dofile("script/c16199990.lua") end)
local m,cm=rk.set(16114220)
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,m+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
	--to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_PAY_LPCOST)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCost(cm.tgcon)
	e2:SetTarget(cm.tgtg)
	e2:SetOperation(cm.tgop)
	c:RegisterEffect(e2)
end
--Activate
function cm.cfilter(c,code)
	return c:IsFaceup() and c:IsOriginalCodeRule(code)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,0,tp,LOCATION_GRAVE)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local ge1=Effect.CreateEffect(e:GetHandler())
	ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ge1:SetCode(EVENT_RECOVER)
	ge1:SetReset(RESET_PHASE+PHASE_END)
	ge1:SetOperation(cm.checkop)
	Duel.RegisterEffect(ge1,tp)
end
function cm.check(c)
	return c:IsSetCard(0xccf) and c:IsAbleToHand() and c:IsType(TYPE_MONSTER)
end
function cm.checkop(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp and Duel.IsExistingMatchingCard(cm.check,tp,LOCATION_GRAVE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(m,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
		local rg=Duel.SelectMatchingCard(tp,cm.check,tp,LOCATION_GRAVE,0,1,1,nil)
		Duel.HintSelection(rg)
		Duel.SendtoHand(rg,tp,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,rg)
	end 
end
--
function cm.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp 
end
function cm.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,tp,0)
end
function cm.tgop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsAbleToHand() then
		Duel.SendtoHand(c,tp,REASON_EFFECT)
	end
end