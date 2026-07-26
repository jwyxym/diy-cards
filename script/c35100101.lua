--异质绝望领主 漆黑质疑者
local m=35100101
local cm=_G["c"..m]
function cm.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,nil,2,4,cm.lcheck)
	local e3=Effect.CreateEffect(c)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(cm.adval)
	c:RegisterEffect(e3)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetTarget(cm.distarget)
	e5:SetCode(EFFECT_IMMUNE_EFFECT)
	e5:SetValue(cm.efilter)
	c:RegisterEffect(e5)
	--negate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m,0))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCountLimit(1,m)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(cm.negcon)
	e2:SetTarget(cm.negtg)
	e2:SetOperation(cm.negop)
	c:RegisterEffect(e2)
end
function cm.lcheck(g,lc)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0xa91)
end
function cm.sefilter(c)
	return c:IsSetCard(0x3a91) and c:IsFaceup()
end
function cm.adval(e,c)
	local g=Duel.GetMatchingGroup(cm.sefilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,e:GetHandler())
	local ct=g:GetClassCount(Card.GetCode)
	return ct*500
end

function cm.distarget(e,c)
	return c:GetMutualLinkedGroupCount()>0 or c==e:GetHandler() and c:IsSetCard(0xa91)
end
function cm.efilter(e,re,rp)
	if e:GetHandlerPlayer()==re:GetHandlerPlayer() then return false end
	return re:IsActiveType(TYPE_SPELL)
end

function cm.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	return (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
function cm.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function cm.negop(e,tp,eg,ep,ev,re,r,rp)
	local tc=re:GetHandler()
	if Duel.NegateActivation(ev) and tc:IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)~=0 then
		local b1=Duel.IsExistingMatchingCard(cm.mvfilter1,tp,LOCATION_MZONE,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)>0
		local b2=Duel.IsExistingMatchingCard(cm.mvfilter2,tp,LOCATION_MZONE,0,1,nil,tp)
		local op
		if b1 and b2 then op=Duel.SelectOption(tp,aux.Stringid(m,1),aux.Stringid(m,2))
		elseif b1 then op=Duel.SelectOption(tp,aux.Stringid(m,1))
		elseif b2 then op=Duel.SelectOption(tp,aux.Stringid(m,2))+1
		else return end
		if op==0 then
			if Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)<=0 then return end
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(m,3))
			local g=Duel.SelectMatchingCard(tp,cm.mvfilter1,tp,LOCATION_MZONE,0,1,1,nil)
			if g:GetCount()>0 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
				local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
				local nseq=math.log(s,2)
				Duel.MoveSequence(g:GetFirst(),nseq)
			end
		else
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(m,4))
			local g1=Duel.SelectMatchingCard(tp,cm.mvfilter2,tp,LOCATION_MZONE,0,1,1,nil,tp)
			local tc1=g1:GetFirst()
			if not tc1 then return end
			Duel.HintSelection(g1)
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(m,4))
			local g2=Duel.SelectMatchingCard(tp,cm.mvfilter3,tp,LOCATION_MZONE,0,1,1,tc1)
			Duel.HintSelection(g2)
			local tc2=g2:GetFirst()
			Duel.SwapSequence(tc1,tc2)
		end
	end
end
function cm.mvfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0xa91)
end
function cm.mvfilter2(c,tp)
	return c:IsFaceup()  and c:GetSequence()<5 and c:IsSetCard(0xa91)
		and Duel.IsExistingMatchingCard(cm.mvfilter3,tp,LOCATION_MZONE,0,1,c)
end
function cm.mvfilter3(c)
	return c:IsFaceup()  and c:GetSequence()<5 and c:IsSetCard(0xa91)
end