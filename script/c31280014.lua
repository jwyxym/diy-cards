--始源机械神
local s,id,o=GetID()
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	--融合召唤	
	aux.AddFusionProcMixRep(c,false,true,aux.FilterBoolFunction(Card.IsRace,RACE_MACHINE),1,127,s.matfilter1,s.matfilter2)
	c:EnableReviveLimit()
	--送去墓地
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(s.tgcon)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	--特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
    e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_GRAVE)
		ge1:SetOperation(s.checkop1)
		Duel.RegisterEffect(ge1,0)   
        local ge2=ge1:Clone()
		ge2:SetCode(EVENT_REMOVE)
        ge2:SetOperation(s.checkop2)
		Duel.RegisterEffect(ge2,0)
    end
end
function s.matfilter1(c)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_MACHINE) and c:IsLevelAbove(8)
end
function s.matfilter2(c,fc)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsControler(fc:GetControler())
end
function s.checkop1(e,tp,eg,ep,ev,re,r,rp)
	for tc in aux.Next(eg) do
    	local p=tc:GetControler()
    	if tc:IsRace(RACE_MACHINE) then
			Duel.RegisterFlagEffect(p,id,0,0,0)
        end
	end
end
function s.checkop2(e,tp,eg,ep,ev,re,r,rp)
	for tc in aux.Next(eg) do 
    	local p=tc:GetControler()
        if tc:IsFaceup() and tc:IsPreviousControler(p) and tc:IsRace(RACE_MACHINE) then
			Duel.RegisterFlagEffect(p,id,0,0,0)
        end
	end
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return re and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and c:IsSummonType(SUMMON_TYPE_FUSION)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToGrave() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	local ct=e:GetHandler():GetMaterialCount()
    local dam=Duel.GetFlagEffect(tp,id)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectTarget(tp,Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam*100)
    g:KeepAlive()
	Duel.SetChainLimit(s.limit(g))
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(RESET_CHAIN)
	e1:SetCountLimit(1)
	e1:SetLabelObject(g)
	e1:SetOperation(s.retop)
	e1:SetReset(RESET_CHAIN)
	Duel.RegisterEffect(e1,tp)
end
function s.limit(g)
	return  function (e,lp,tp)
				return not g:IsContains(e:GetHandler())
			end
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():DeleteGroup()
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)    
	Duel.SendtoGrave(g,REASON_EFFECT)
    local dam=Duel.GetFlagEffect(tp,id)
    Duel.Damage(1-tp,dam*400,REASON_EFFECT)        
end
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsRace(RACE_MACHINE) and not c:IsCode(id)
    	and (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_REMOVED+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_REMOVED+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_REMOVED+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end