--路观大王
local s,id=GetID()
function s.initial_effect(c)
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkAttribute,ATTRIBUTE_WATER),3,3,s.lkcheck)
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetOperation(s.e1op)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
end


function s.lkcheck(g)
	return g:GetClassCount(Card.GetLinkRace)==g:GetCount()
end


function s.e1op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ops={}
	local opval={}
	if e:GetHandler():GetFlagEffectLabel(id+0)~=Duel.GetTurnCount()-1 then
		table.insert(ops,aux.Stringid(id,0))
		table.insert(opval,0)
	end
	if e:GetHandler():GetFlagEffectLabel(id+1)~=Duel.GetTurnCount()-1
	and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) then
		table.insert(ops,aux.Stringid(id,1))
		table.insert(opval,1)
	end
	if e:GetHandler():GetFlagEffectLabel(id+2)~=Duel.GetTurnCount()-1 then
		table.insert(ops,aux.Stringid(id,2))
		table.insert(opval,2)
	end
	if e:GetHandler():GetFlagEffectLabel(id+3)~=Duel.GetTurnCount()-1
	and not Duel.IsExistingMatchingCard(s.tokenfilter,tp,LOCATION_MZONE,0,1,nil)
	and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		table.insert(ops,aux.Stringid(id,3))
		table.insert(opval,3)
	end
	if e:GetHandler():GetFlagEffectLabel(id+4)~=Duel.GetTurnCount()-1
	and Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil) then
		table.insert(ops,aux.Stringid(id,4))
		table.insert(opval,4)
	end
	if #ops==0 then return end
	local sel=Duel.SelectOption(tp,table.unpack(ops))
	local op=opval[sel+1]
	c:RegisterFlagEffect(id+op,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2,Duel.GetTurnCount())
	if op==0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetValue(s.efilter)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		c:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		c:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_CANNOT_ATTACK)
		c:RegisterEffect(e3)
		local e4=e2:Clone()
		e4:SetCode(EFFECT_CANNOT_TRIGGER)
		c:RegisterEffect(e4)
	end
	if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_CANNOT_TRIGGER)
			tc:RegisterEffect(e2)
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
			local e4=Effect.CreateEffect(c)
			e4:SetType(EFFECT_TYPE_SINGLE)
			e4:SetCode(EFFECT_DISABLE_EFFECT)
			e4:SetValue(RESET_TURN_SET)
			e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e4)
		end
	end
	if op==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
		local seq=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
		seq=math.log(seq,2)
		Duel.MoveSequence(c,seq)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
	if op==3 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
			and not Duel.IsExistingMatchingCard(s.tokenfilter,tp,LOCATION_MZONE,0,1,nil) then
			local token=Duel.CreateToken(tp,41990006)
			Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	if op==4 then
		local ct=1
		if Duel.IsExistingMatchingCard(s.tokenfilter,tp,LOCATION_MZONE,0,1,nil) then
			ct=2
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,ct,nil)
		if #g>0 then
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
function s.efilter(e,re)
	return re:GetOwnerPlayer()~=e:GetHandlerPlayer() and re:IsActiveType(TYPE_MONSTER)
end
function s.tokenfilter(c)
	return c:IsCode(41990006)
end
function s.atkval(e,c)
	if Duel.IsExistingMatchingCard(s.tokenfilter,c:GetControler(),LOCATION_MZONE,0,1,nil) then
		return 500
	end
	return 0
end