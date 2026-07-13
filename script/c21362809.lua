--魔诞 穿刺将军
function c21362809.initial_effect(c)
	--summon with 1 tribute
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21362809,0))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(c21362809.otcon)
	e1:SetOperation(c21362809.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	--ctde 
	local e2=Effect.CreateEffect(c)  
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O) 
	e2:SetCode(EVENT_TO_GRAVE)  
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE+LOCATION_REMOVED)
	e2:SetCountLimit(1,11362809) 
	e2:SetCost(c21362809.ctdcost)
	e2:SetTarget(c21362809.ctdtg)
	e2:SetOperation(c21362809.ctdop)
	c:RegisterEffect(e2)
end
function c21362809.cfilter(c,tp)
	if c:IsLocation(LOCATION_DECK) then 
		return c:IsAbleToGrave() and c:IsSetCard(0xba38) and not c:IsCode(21362809)
	else 
		return c:IsReleasable()
	end 
end
function c21362809.rlgck(g,tp) 
	return Duel.GetMZoneCount(tp,g)>0  
end 
function c21362809.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	local mg=Duel.GetMatchingGroup(c21362809.cfilter,tp,LOCATION_MZONE+LOCATION_DECK,0,nil,tp)
	return c:IsLevelAbove(7) and mg:CheckSubGroup(c21362809.rlgck,2,2,tp)
end
function c21362809.otop(e,tp,eg,ep,ev,re,r,rp,c)
	local mg=Duel.GetMatchingGroup(c21362809.cfilter,tp,LOCATION_MZONE+LOCATION_DECK,0,nil,tp)
	local smg=mg:SelectSubGroup(tp,c21362809.rlgck,false,2,2,tp)
	c:SetMaterial(smg) 
	local xg=smg:Filter(Card.IsLocation,nil,LOCATION_DECK) 
	if xg:GetCount()>0 then 
		Duel.SendtoGrave(xg,REASON_SUMMON+REASON_MATERIAL) 
		smg:Sub(xg) 
	end 
	Duel.Release(smg,REASON_SUMMON+REASON_MATERIAL)
end
function c21362809.ctdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeckAsCost() end
	Duel.SendtoDeck(e:GetHandler(),nil,2,REASON_COST) 
end
function c21362809.ctdfilter(c)
	return c:IsSetCard(0xba38) and c:IsAbleToHand()
end
function c21362809.ctdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end 
end
function c21362809.ctdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(e:GetHandler()) 
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE) 
	e1:SetValue(c21362809.atkval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp) 
end
function c21362809.atkval(e) 
	local tp=e:GetHandlerPlayer() 
	return Duel.GetMatchingGroupCount(function(c) return c:IsFaceup() and c:IsRace(RACE_FIEND) end,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)*-400
end

 