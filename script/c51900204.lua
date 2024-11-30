--创世之母-提亚马特
function c51900204.initial_effect(c)
	c:EnableReviveLimit()
	--spsummon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(function(e,se,sp,st)
	return st&SUMMON_TYPE_RITUAL~=SUMMON_TYPE_RITUAL or (se and se:GetHandler():IsCode(51900205)) end)
	c:RegisterEffect(e1)
	--
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK) 
	e1:SetRange(LOCATION_MZONE)  
	c:RegisterEffect(e1)
	--battle target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)	
	--immune
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(function(e,te)
	return te:GetOwner()~=e:GetOwner() end)
	c:RegisterEffect(e1) 
	--skip
	local e2=Effect.CreateEffect(c) 
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_IGNITION) 
	e2:SetRange(LOCATION_MZONE)  
	e2:SetCountLimit(1,51900204) 
	e2:SetCost(c51900204.cost)
	e2:SetTarget(c51900204.sktg)
	e2:SetOperation(c51900204.skop)
	c:RegisterEffect(e2) 
	--disable spsummon
	local e3=Effect.CreateEffect(c) 
	e3:SetCategory(CATEGORY_CONTROL)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,51900204) 
	e3:SetCondition(c51900204.dscon)
	e3:SetCost(c51900204.cost)
	e3:SetTarget(c51900204.dstg)
	e3:SetOperation(c51900204.dsop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4) 
	--special summon
	local e4=Effect.CreateEffect(c) 
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O) 
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_REMOVED)
	e4:SetCountLimit(1) 
	e4:SetTarget(c51900204.sptg)
	e4:SetOperation(c51900204.spop)
	c:RegisterEffect(e4)
end
function c51900204.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() end
	if Duel.Remove(c,0,REASON_COST+REASON_TEMPORARY)~=0 and c:GetOriginalCode()==id then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(c)
		e1:SetCountLimit(1)
		e1:SetOperation(c51900204.retop)
		Duel.RegisterEffect(e1,tp)
	end
end
function c51900204.sktg(e,tp,eg,ep,ev,re,r,rp,chk)  
	if chk==0 then return true end 
end
function c51900204.skop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,1) 
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	Duel.RegisterEffect(e1,tp)  
end 
function c51900204.dscon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and Duel.GetCurrentChain()==0
end
function c51900204.dstg(e,tp,eg,ep,ev,re,r,rp,chk)  
	if chk==0 then return eg:FilterCount(Card.IsControlerCanBeChanged,nil)==eg:GetCount() and Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_CONTROL)>=eg:GetCount() end
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,eg,eg:GetCount(),0,0) 
end
function c51900204.dsop(e,tp,eg,ep,ev,re,r,rp)
	Duel.GetControl(eg,tp)
end
function c51900204.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c51900204.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end



