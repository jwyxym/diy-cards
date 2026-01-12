--冻雪冰心·菲琳
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,31280114)
	--同调召唤
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER),aux.NonTuner(s.mfilter),1,1)
	c:EnableReviveLimit()
	--适用效果    
    local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(s.check)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetLabelObject(e0)
	e1:SetCondition(s.efcon)
    e1:SetTarget(s.eftg)
	e1:SetOperation(s.efop)
	c:RegisterEffect(e1)
	--除外    
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o*10000)
	e2:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMING_END_PHASE)
	e2:SetCost(s.rmcost)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
	--特殊召唤
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)    
end
s.material_type=TYPE_SYNCHRO
function s.mfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_SYNCHRO)
end
function s.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO)
end
function s.check(e,c)
	if c:GetMaterial():IsExists(s.cfilter,1,nil) then 
    	e:SetLabel(1) 
    else 
    	e:SetLabel(0) 
    end
end
function s.efcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) and e:GetLabelObject():GetLabel()==1
end
function s.eftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.disfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsLevelAbove(1) and not c:IsPublic()
end    
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler() 
	if Duel.IsChainDisablable(0) and Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 then
		local g=Duel.GetMatchingGroup(s.disfilter,tp,0,LOCATION_HAND,nil)
        local sel=1
		Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(id,3))
		if g:GetCount()>0 then
			sel=Duel.SelectOption(1-tp,1213,1214)
		else
			sel=Duel.SelectOption(1-tp,1214)+1
		end
		if sel==0 then
        	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CONFIRM)
			local tc=g:Select(1-tp,1,1,nil):GetFirst()            
			--公开            
            local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_PUBLIC)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			--攻守变化            
            local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)            
			e2:SetValue(s.atkval)
            e2:SetLabelObject(tc)
			e2:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e2,tp)
            local e3=e2:Clone()
			e3:SetCode(EFFECT_UPDATE_DEFENSE)
            Duel.RegisterEffect(e3,tp)
            Duel.NegateEffect(0)
			return
        end    
	end
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetTargetRange(0,LOCATION_HAND)      
    e1:SetTarget(s.lvtg)      
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)       
end
function s.atkval(e,c)
	local r=c:GetAttribute()
    local lv=e:GetLabelObject():GetLevel()
	if bit.band(r,ATTRIBUTE_WATER)~=0 then return lv*200
	else return -lv*200 end
end
function s.lvtg(e,c)
	return c:IsType(TYPE_MONSTER) and c:IsLevelAbove(1)
end
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil,tp) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,nil,tp)
end
function s.rmfilter(c)
	return c:IsFaceup() and c:IsAbleToRemove() and c:GetAttack()<c:GetTextAttack() 
end    
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,LOCATION_MZONE)
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local sg=g:Select(tp,1,1,nil)
		Duel.HintSelection(sg)
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	end
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_MZONE) and e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.spfilter(c,e,tp)
	return c:IsCode(31280114) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if tc then
		tc:SetMaterial(nil)
		if Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
			tc:CompleteProcedure()
		end            
	end            
end