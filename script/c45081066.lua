--重力重压
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--atk
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+1)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.bttg)
	e2:SetOperation(s.btop)
	c:RegisterEffect(e2)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x186) and c:IsType(TYPE_LINK)
end
function s.cfilter2(c)
	return c:IsFaceup() and c:GetMutualLinkedGroupCount()>0
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	local dg=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	local mg=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
	local ct=1
	if Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_MZONE,0,1,nil) 
		and #mg>0 then
		ct=#mg
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,ct,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,CATEGORY_DESTROY)
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	if #g==0 then return end
	local check=Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_MZONE,0,1,nil)
	local mg=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
	if #g==1 then
		Duel.Destroy(g,REASON_EFFECT)
	else
		if not check or #mg==0 or 
			(check and not Duel.SelectYesNo(tp,aux.Stringid(id,1))) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local dg=g:Select(tp,1,1,nil)
			Duel.HintSelection(dg)
			Duel.Destroy(dg,REASON_EFFECT)
		else
			Duel.Destroy(mg,REASON_EFFECT)
		end
	end
end
function s.bttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if chk==0 then
		if not d then return false end
		if not a:IsControler(tp) then a,d=d,a end
		return a:IsType(TYPE_LINK) and a:IsSetCard(0x186)
			and a:IsControler(tp) and not d:IsControler(tp) 
	end
	local tc=a:IsControler(tp) and a or d
	Duel.SetTargetCard(tc)
end

function s.btop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local a,d=Duel.GetAttacker(),Duel.GetAttackTarget()
	if not a:IsControler(tp) then a,d=d,a end
	if d:IsFaceup() and d:IsRelateToBattle() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		d:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		d:RegisterEffect(e2)
		Duel.AdjustInstantly(c)
		if a:IsFaceup() and a:IsRelateToBattle()
			and a:IsType(TYPE_LINK) and a:IsSetCard(0x186) then
			--ATK 
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_UPDATE_ATTACK)
			e3:SetValue(a:GetLink()*-1000)
			e3:SetReset(RESET_EVENT|RESETS_STANDARD)
			d:RegisterEffect(e3)
		end
	end
end