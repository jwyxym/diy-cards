--圣铠帝 阿尔卡迪亚斯
if not pcall(function() require("expansions/script/c16110001") end) then require("script/c16110001") end
local m,cm=rk.set(16110034,"alcadias")
function cm.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcCode2(c,16110015,16110036,true,true)
	--Effect 1
	aux.EnableChangeCode(c,16110015,LOCATION_MZONE+LOCATION_GRAVE)
	--Effect 2  
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(m,0))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,m)
	e3:SetCondition(cm.con)
	e3:SetTarget(cm.tg)
	e3:SetOperation(cm.op)
	c:RegisterEffect(e3)
	--Effect 3 
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(m,1))
	e5:SetCategory(CATEGORY_REMOVE)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_MSET)
	e5:SetRange(LOCATION_MZONE)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCountLimit(1,m+100)
	e5:SetCondition(cm.damcon2)
	e5:SetTarget(cm.damtg3)
	e5:SetOperation(cm.damop3)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EVENT_SSET)
	c:RegisterEffect(e6)
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(m,1))
	e7:SetCategory(CATEGORY_REMOVE)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e7:SetCode(EVENT_CHANGE_POS)
	e7:SetRange(LOCATION_MZONE)
	e7:SetProperty(EFFECT_FLAG_DELAY)
	e7:SetCountLimit(1,m+100)
	e7:SetCondition(cm.damcon3)
	e7:SetTarget(cm.damtg3)
	e7:SetOperation(cm.damop3)
	c:RegisterEffect(e7)
end
--Effect 2
function cm.con(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) 
	and re:IsActiveType(TYPE_MONSTER) 
	and Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)==LOCATION_GRAVE and rp==1-tp
end
function cm.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	if chk==0 then return rc:IsRelateToEffect(re) and rc:IsAbleToRemove() and not rc:IsLocation(LOCATION_REMOVED) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,rc,1,0,0)
end
function cm.op(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if rc:IsRelateToEffect(re) then
		Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)
	end
end
--Effect 3 
function cm.damcon2(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp
end
function cm.cfilter(c,tp,rp)
	return c:IsFacedown() and rp==tp
end
function cm.damcon3(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cm.cfilter,1,nil,1-tp,rp)
end
function cm.damtg3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND,1,nil) end
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,1-tp,1)
end
function cm.damop3(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,p,0,LOCATION_HAND,nil)
	if g:GetCount()>0 then
		Duel.ConfirmCards(p,g)
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_REMOVE)
		local sg=g:Select(p,1,1,nil)
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
		Duel.ShuffleHand(1-p)
	end
end 
