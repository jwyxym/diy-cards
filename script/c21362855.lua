--魔诞 凶怖霸王
function c21362855.initial_effect(c)
	--xx
	local e1=Effect.CreateEffect(c) 
	e1:SetType(EFFECT_TYPE_IGNITION)  
	e1:SetRange(LOCATION_HAND) 
	e1:SetCost(c21362855.xxcost) 
	e1:SetOperation(c21362855.xxop)
	c:RegisterEffect(e1) 
	--to hand 
	local e2=Effect.CreateEffect(c) 
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE+LOCATION_REMOVED)
	e2:SetCountLimit(1,21362855)
	e2:SetCondition(c21362855.thcon) 
	e2:SetTarget(c21362855.thtg)
	e2:SetOperation(c21362855.thop)
	c:RegisterEffect(e2) 
	local e3=e2:Clone() 
	e3:SetCode(EVENT_SPSUMMON_SUCCESS) 
	c:RegisterEffect(e3) 
end 
function c21362855.xxcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function c21362855.xxop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler() 
	if Duel.GetFlagEffect(tp,21362855)==0 then 
		--Tribute Summon
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(21362855,0))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SUMMON_PROC)
		e1:SetTargetRange(LOCATION_HAND,0) 
		e1:SetCondition(c21362855.otcon)
		e1:SetTarget(c21362855.ottg)
		e1:SetOperation(c21362855.otop) 
		e1:SetValue(SUMMON_TYPE_ADVANCE) 
		e1:SetReset(RESET_PHASE+PHASE_END) 
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_PROC)
		c:RegisterEffect(e2)  
	end 
	Duel.RegisterFlagEffect(tp,21362855,RESET_PHASE+PHASE_END,0,1)
	local flag=Duel.GetFlagEffectLabel(tp,21362855)  
	if flag==nil then 
		Duel.RegisterFlagEffect(tp,21362855,0,0,0,1)
	else 
		Duel.SetFlagEffectLabel(tp,21362855,flag+1)
	end 
end 
function c21362855.otfilter(c,e,tp)
	return c:IsSetCard(0xba38) and Duel.GetMZoneCount(tp,c)>0
end 
function c21362855.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler() 
	return Duel.IsExistingMatchingCard(c21362855.otfilter,tp,LOCATION_DECK,0,1,nil,e,tp) 
end
function c21362855.ottg(e,c)
	local mi,ma=c:GetTributeRequirement()
	return ma>0 and c:IsSetCard(0xba38)
end
function c21362855.otop(e,tp,eg,ep,ev,re,r,rp,c) 
	local flag=Duel.GetFlagEffectLabel(tp,21362855)  
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectMatchingCard(tp,c21362855.otfilter,tp,LOCATION_DECK,0,1,flag,nil,e,tp) 
	Duel.Release(g,REASON_COST)
	c:SetMaterial(nil)
end
function c21362855.thcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	return ec:IsControler(tp) and ec:IsSetCard(0xba38)
end
function c21362855.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function c21362855.sumfilter(c)
	return c:IsSummonable(true,nil)  
end
function c21362855.thop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT) and Duel.IsExistingMatchingCard(c21362855.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(21362855,1)) then
		Duel.BreakEffect()
		Duel.ShuffleHand(tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
		local sg=Duel.SelectMatchingCard(tp,c21362855.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
		if sg:GetCount()>0 then
			Duel.Summon(tp,sg:GetFirst(),true,nil)
		end
	end
end



