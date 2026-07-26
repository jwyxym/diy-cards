--异质绝望领主 僧侣怪医
local m=35100107
local cm=_G["c"..m]
function cm.initial_effect(c)
	--link summon
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0xa91),2,2)
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xa91))
	e1:SetValue(cm.val1)
	c:RegisterEffect(e1)
	--negate
	local e21=Effect.CreateEffect(c)
	e21:SetDescription(aux.Stringid(m,0))
	e21:SetCategory(CATEGORY_NEGATE+CATEGORY_DAMAGE)
	e21:SetType(EFFECT_TYPE_QUICK_O)
	e21:SetCode(EVENT_CHAINING)
	e21:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e21:SetCountLimit(1,m)
	e21:SetRange(LOCATION_MZONE)
	e21:SetCondition(cm.negcon)
	e21:SetTarget(cm.negtg)
	e21:SetOperation(cm.negop)
	c:RegisterEffect(e21)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,m+1)
	e2:SetCondition(cm.spcon)
	e2:SetTarget(cm.mvtg)
	e2:SetOperation(cm.mvop)
	c:RegisterEffect(e2)
end
function cm.lcheck(g,lc)
	return g:GetClassCount(Card.GetLinkCode)==g:GetCount()
end

function cm.vfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0xa91)
end
function cm.val1(e)
	local lv=0
	local tp=e:GetHandler():GetControler()
	local mc=Duel.GetMatchingGroupCount(cm.vfilter1,tp,LOCATION_SZONE,0,nil)
	return mc*300
end

function cm.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
	 and c:GetMutualLinkedGroupCount()>0 and re:GetHandler():IsType(TYPE_TRAP)
end
function cm.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,1,0,0)
end
function cm.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateActivation(ev)
	Duel.Damage(1-tp,1000,REASON_EFFECT)
end

function cm.spcon(e,tp,eg,ep,ev,re,r,rp)
	return (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
function cm.mvfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0xa91)
end
function cm.mvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local b1=Duel.IsExistingMatchingCard(cm.mvfilter1,tp,LOCATION_MZONE,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)>0
	if chk==0 then return b1 and Duel.IsExistingMatchingCard(cm.setfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.RegisterFlagEffect(tp,m,RESET_EVENT+RESET_PHASE+PHASE_END,0,0)  
end
function cm.mvop(e,tp,eg,ep,ev,re,r,rp)
	local b1=Duel.IsExistingMatchingCard(cm.mvfilter1,tp,LOCATION_MZONE,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)>0
	if b1 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(m,3))
		local g=Duel.SelectMatchingCard(tp,cm.mvfilter1,tp,LOCATION_MZONE,0,1,1,nil)
		if g:GetCount()>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
			local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
			local nseq=math.log(s,2)
			Duel.MoveSequence(g:GetFirst(),nseq)
		end
		if Duel.IsExistingMatchingCard(cm.setfilter,tp,LOCATION_DECK,0,1,nil) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
			local tc=Duel.SelectMatchingCard(tp,cm.setfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
			if tc and Duel.SSet(tp,tc)~=0 then
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
				e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
			end
		end
	end
end
function cm.setfilter(c)
	return c:IsSetCard(0xa91) and c:IsSSetable() and c:IsType(TYPE_TRAP)
end