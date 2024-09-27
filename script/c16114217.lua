--暴歌仙精 雅拉之歌
xpcall(function() dofile("expansions/script/c16199990.lua") end,function() dofile("script/c16199990.lua") end)
local m,cm=rk.set(16114217)
function cm.initial_effect(c)
	--link summon
	aux.AddLinkProcedure(c,nil,2,2,cm.lcheck)
	c:EnableReviveLimit()
	--battle
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(cm.immune)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--recover
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m,0))
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_PAY_LPCOST)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCost(cm.reccon)
	e2:SetTarget(cm.rectg)
	e2:SetOperation(cm.recop)
	c:RegisterEffect(e2)
	--search
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(m,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1)
	e3:SetCondition(cm.seacon)
	e3:SetTarget(cm.seatg)
	e3:SetOperation(cm.seaop)
	c:RegisterEffect(e3)
end
--linkfilter
function cm.linkfilter(c)
	return c:IsSetCard(0xccf)
end
function cm.lcheck(g,lc)
	return g:IsExists(cm.linkfilter,1,nil)
end
--e1
function cm.immune(e,c)
	return (c:IsSetCard(0xccf) and c:IsType(TYPE_MONSTER))
end
--e2
function cm.reccon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp 
end
function cm.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(200)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,200)
end
function cm.recop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Recover(p,d,REASON_EFFECT)
end
--e3
function cm.seaconf(c,tp)
	return c:GetPreviousControler()==tp and c:IsReason(REASON_EFFECT)
end
function cm.seacon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cm.seaconf,1,nil,tp)
end
function cm.seatgf(c)
	return c:IsSetCard(0xccf) and c:IsAbleToHand()
end
function cm.seatg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.seatgf,tp,LOCATION_DECK,0,3,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
function cm.seaop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(cm.seatgf,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>=3 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,3,3,nil)
		Duel.ConfirmCards(1-tp,sg)
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)
		local tg=sg:Select(1-tp,1,1,nil)
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end