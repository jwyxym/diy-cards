--逐火之旅 哀地里亚
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id+o*10000)
	e2:SetTarget(s.acttg)
	e2:SetOperation(s.actop)
	c:RegisterEffect(e2)
	--necro valley
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e6:SetCode(EFFECT_NECRO_VALLEY)
	e6:SetRange(LOCATION_FZONE)
	e6:SetTargetRange(LOCATION_GRAVE,LOCATION_GRAVE)
	e6:SetCondition(s.contp)
	c:RegisterEffect(e6)
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD)
	e8:SetCode(EFFECT_NECRO_VALLEY)
	e8:SetRange(LOCATION_FZONE)
	e8:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e8:SetTargetRange(1,1)
	e8:SetCondition(s.contp)
	c:RegisterEffect(e8)
	--disable
	local e10=Effect.CreateEffect(c)
	e10:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e10:SetCode(EVENT_CHAIN_SOLVING)
	e10:SetRange(LOCATION_FZONE)
	e10:SetOperation(s.disop)
	c:RegisterEffect(e10)
end
function s.thfilter(c)
	return (c:IsCode(47700110) or c:IsSetCard(0x473)) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function s.actfilter(c,tp)
	return not c:IsCode(id) and c:IsSetCard(0x472) and c:IsType(TYPE_FIELD) and c:GetActivateEffect():IsActivatable(tp,true,true)
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.actfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,tp) end
	if not Duel.CheckPhaseActivity() then e:SetLabel(1) else e:SetLabel(0) end
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(11881272,2))
	if e:GetLabel()==1 then Duel.RegisterFlagEffect(tp,11881272,RESET_CHAIN,0,1) end
	local g=Duel.SelectMatchingCard(tp,s.actfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,tp)
	Duel.ResetFlagEffect(tp,11881272)
	local tc=g:GetFirst()
	if tc then
		local te=tc:GetActivateEffect()
		if e:GetLabel()==1 then Duel.RegisterFlagEffect(tp,11881272,RESET_CHAIN,0,1) end
		local b=te:IsActivatable(tp,true,true)
		if b then
			Duel.ResetFlagEffect(tp,11881272)
			local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
			if fc then
				Duel.SendtoGrave(fc,REASON_RULE)
				Duel.BreakEffect()
			end
			Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
			te:UseCountLimit(tp,1,true)
			local tep=tc:GetControler()
			local cost=te:GetCost()
			if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
			Duel.RaiseEvent(tc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
		end
	end
end
function s.contp(e)
	return Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsCode),e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil,47700115)
end
function s.disfilter(c,re)
	return c:IsHasEffect(EFFECT_NECRO_VALLEY) and c:IsRelateToEffect(re)
end
function s.discheck(ev,category,re,im0,im1)
	local ex,tg,ct,p,v=Duel.GetOperationInfo(ev,category)
	if not ex then return false end
	if v==LOCATION_GRAVE and ct>0 then
		if p==0 then return im0
		elseif p==1 then return im1
		elseif p==PLAYER_ALL then return im0 and im1
		end
	end
	if tg and tg:GetCount()>0 then
		return tg:IsExists(s.disfilter,1,nil,re)
	end
	return false
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local tc=re:GetHandler()
	if not Duel.IsChainDisablable(ev) or tc:IsHasEffect(EFFECT_NECRO_VALLEY_IM) then return end
	local res=false
	local im0=not Duel.IsPlayerAffectedByEffect(0,EFFECT_NECRO_VALLEY_IM)
	local im1=not Duel.IsPlayerAffectedByEffect(1,EFFECT_NECRO_VALLEY_IM)
	if not res and s.discheck(ev,CATEGORY_SPECIAL_SUMMON,re,im0,im1) then res=true end
	if not res and s.discheck(ev,CATEGORY_TOHAND,re,im0,im1) then res=true end
	if not res and s.discheck(ev,CATEGORY_TODECK,re,im0,im1) then res=true end
	if not res and s.discheck(ev,CATEGORY_TOEXTRA,re,im0,im1) then res=true end
	if not res and s.discheck(ev,CATEGORY_LEAVE_GRAVE,re,im0,im1) then res=true end
	if not res and s.discheck(ev,CATEGORY_REMOVE,re,im0,im1) then res=true end
	if res then Duel.NegateEffect(ev,true) end
end