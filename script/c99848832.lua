-- 命运女郎·蒂尔
local s,id,o=GetID()
function s.initial_effect(c)
  
	aux.AddFusionProcCodeRep(c,aux.FilterBoolFunction(Card.IsSetCard,0x31),2,2,true)
	c:EnableReviveLimit()
	

	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.ntcon)
	e0:SetOperation(s.ntop)
	e0:SetCountLimit(1,id)  
	c:RegisterEffect(e0)
	

	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_DEFENSE)
	c:RegisterEffect(e2)
	

	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.lvcon)
	e3:SetOperation(s.lvop)
	c:RegisterEffect(e3)
	
   
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+100)  
	e4:SetCost(s.spcost)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end


function s.ntfilter(c,tp)
	return c:IsSetCard(0x31) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
		and (c:IsControler(tp) or c:IsLocation(LOCATION_HAND) or c:IsLocation(LOCATION_GRAVE))
		and (c:IsLocation(LOCATION_HAND) or c:IsLocation(LOCATION_MZONE) or c:IsLocation(LOCATION_GRAVE))
end

function s.ntcon(e,c,og,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(s.ntfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,nil,tp)
	

	if #g<2 then return false end
	

	local field_material_count=0
	local field_material_list={}
	for tc in aux.Next(g) do
		if tc:IsLocation(LOCATION_MZONE) then
			field_material_count=field_material_count+1
			table.insert(field_material_list,tc)
		end
	end
	

	local current_zone_count=Duel.GetLocationCount(tp,LOCATION_MZONE)
	

	if field_material_count==0 then
		return current_zone_count>0
	end
	
   
	local can_select_field=false
	for _,tc in ipairs(field_material_list) do
	  
		can_select_field=true
		break
	end
	
	if not can_select_field then
		return current_zone_count>0
	end
	
	
	return true
end

function s.ntop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.GetMatchingGroup(s.ntfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,nil,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg=g:Select(tp,2,2,nil)
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end


function s.atkval(e,c)
	local lv=c:GetLevel()
	return lv*400
end


function s.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end


function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) and c:GetLevel()<12 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end


function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end


function s.spfilter(c,e,tp)
	return c:IsSetCard(0x31) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end


function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end