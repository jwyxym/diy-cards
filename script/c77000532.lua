--临界精灵 梦魇-囁吿篇帙
function c77000532.initial_effect(c)
	--fusion summon
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0xee2),2,true)
	--spsummon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.fuslimit)
	e1:SetRange(LOCATION_EXTRA)
	c:RegisterEffect(e1)
	--SpecialSummon  
	local e1=Effect.CreateEffect(c) 
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O) 
	e1:SetCode(EVENT_CHAINING)  
	e1:SetRange(LOCATION_MZONE) 
	e1:SetCountLimit(1,77000532) 
	e1:SetCondition(c77000532.hspcon)
	e1:SetTarget(c77000532.hsptg) 
	e1:SetOperation(c77000532.hspop) 
	c:RegisterEffect(e1)  
	--remove 
	local e2=Effect.CreateEffect(c) 
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,17000532)
	e2:SetCondition(c77000532.rmcon)
	e2:SetTarget(c77000532.rmtg)
	e2:SetOperation(c77000532.rmop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--remove 
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOEXTRA+CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O) 
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)  
	e2:SetRange(LOCATION_REMOVED)
	e2:SetTarget(c77000532.tertg)
	e2:SetOperation(c77000532.terop)
	c:RegisterEffect(e2)
end
function c77000532.hspcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp 
end 
function c77000532.hsptg(e,tp,eg,ep,ev,re,r,rp,chk) 
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and g:GetCount()>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,1-tp,LOCATION_HAND)
end
function c77000532.spfil(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp) 
end
function c77000532.hspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND) 
	if g:GetCount()>0 then 
		Duel.ConfirmCards(tp,g)  
		if g:Filter(c77000532.spfil,nil,e,tp):GetCount()>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 then 
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local tc=g:Filter(c77000532.spfil,nil,e,tp):Select(tp,1,1,nil):GetFirst()
			Duel.SpecialSummonStep(tc,0,tp,1-tp,false,false,POS_FACEUP) 
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2) 
			Duel.SpecialSummonComplete()
		end
		Duel.ShuffleHand(1-tp)  
	end  
end 
function c77000532.cfilter(c,sp)
	return c:IsSummonPlayer(sp)
end
function c77000532.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c77000532.cfilter,1,nil,1-tp)
end 
function c77000532.rmfil(c) 
	return c:IsSetCard(0xee2) and c:IsAbleToRemove()  
end 
function c77000532.rmtg(e,tp,eg,ep,ev,re,r,rp,chk) 
	if chk==0 then return Duel.IsExistingMatchingCard(c77000532.rmfil,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end 
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function c77000532.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.SelectMatchingCard(tp,c77000532.rmfil,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil):GetFirst() 
	if tc then 
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT) 
	end 
end 
function c77000532.tckfil(c,tp) 
	return c:IsReason(REASON_EFFECT+REASON_BATTLE)  
end 
function c77000532.tercon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c77000532.tckfil,1,nil,tp)
end 
function c77000532.tertg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToExtra() end 
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,e:GetHandler(),1,0,0) 
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end 
function c77000532.terop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler() 
	if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT)~=0 then 
		Duel.BreakEffect() 
		Duel.Recover(tp,500,REASON_EFFECT) 
	end
end 


