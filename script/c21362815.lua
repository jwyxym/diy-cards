--魔诞 哀伤枯树
function c21362815.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c)  
	--spirit return
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP,EVENT_SPSUMMON_SUCCESS)
	--spsummon
	local e1=Effect.CreateEffect(c) 
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCountLimit(1,21362815)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(c21362815.xpcon)
	e1:SetTarget(c21362815.xptg)
	e1:SetOperation(c21362815.xpop)
	c:RegisterEffect(e1)
	-- 
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21362815,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_GRAVE+LOCATION_EXTRA)
	e2:SetCountLimit(1,11362815)
	e2:SetCondition(c21362815.spcon)
	e2:SetTarget(c21362815.sptg)
	e2:SetOperation(c21362815.spop)
	c:RegisterEffect(e2)
	--xx
	local e1=Effect.CreateEffect(c) 
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O) 
	e1:SetCode(EVENT_CHAINING) 
	e1:SetProperty(EFFECT_FLAG_DELAY)  
	e1:SetRange(LOCATION_PZONE) 
	e1:SetCountLimit(1,31362815) 
	e1:SetTarget(c21362815.xxtg) 
	e1:SetOperation(c21362815.xxop) 
	c:RegisterEffect(e1) 
end
function c21362815.xpcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsReason(REASON_DRAW)
end
function c21362815.xptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=(Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
	local b2=e:GetHandler():IsAbleToExtra()
	if chk==0 then return b1 or b2 end 
end
function c21362815.xpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end 
	local b1=(Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
	local b2=e:GetHandler():IsAbleToExtra()
	if b1 or b2 then 
		local op=aux.SelectFromOptions(tp,{b1,aux.Stringid(21362815,1)},{b2,aux.Stringid(21362815,2)})
		if op==1 then 
			Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		end 
		if op==2 then 
			Duel.SendtoExtraP(c,tp,REASON_EFFECT) 
		end 
	end 
end
function c21362815.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and Duel.GetTurnPlayer()==1-tp 
end
function c21362815.sptg(e,tp,eg,ep,ev,re,r,rp,chk) 
	local b1=e:GetHandler():IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,e:GetHandler())>0 
	local b2=e:GetHandler():IsLocation(LOCATION_GRAVE) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chk==0 then return (b1 or b2) and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c21362815.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) 
		Duel.BreakEffect()
		local e1=Effect.CreateEffect(c) 
		e1:SetType(EFFECT_TYPE_FIELD) 
		e1:SetCode(EFFECT_UPDATE_ATTACK) 
		e1:SetTargetRange(0,LOCATION_MZONE) 
		e1:SetValue(-2000) 
		e1:SetReset(RESET_PHASE+PHASE_END) 
		Duel.RegisterEffect(e1,tp) 
	end
end
function c21362815.sumfilter(c)
	return c:IsSummonable(true,nil) and c:IsSetCard(0xba38)
end
function c21362815.xxtg(e,tp,eg,ep,ev,re,r,rp,chk) 
	local b1=Duel.IsExistingMatchingCard(c21362815.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
	local b2=e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chk==0 then return b1 or b2 end 
end
function c21362815.xxop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local b1=Duel.IsExistingMatchingCard(c21362815.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
	local b2=e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
	if b1 and Duel.SelectYesNo(tp,aux.Stringid(21362815,3)) then 
		local tc=Duel.SelectMatchingCard(tp,c21362815.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil):GetFirst() 
		Duel.Summon(tp,tc,true,nil)
	end 
	if b2 and Duel.SelectYesNo(tp,aux.Stringid(21362815,4)) then 
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) 
	end 
end 





