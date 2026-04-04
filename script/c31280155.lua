--小甜心★梅杜莎
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,31280146,31280148,31280149)
	--融合召唤
	aux.AddMaterialCodeList(c,31280146,31280149)
	aux.AddFusionProcCodeFun(c,31280146,{31280149,s.matfilter},1,true,true)
	--装备    
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
    e1:SetCost(s.eqcost)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)    
	--赋予效果    
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.efcon)
	e2:SetOperation(s.efop)
	c:RegisterEffect(e2)    
	--无效    
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.discon)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
end    
function s.matfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsLevelAbove(6)
end
function s.costfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL) and c:IsAbleToDeckOrExtraAsCost()
end
function s.eqfilter(c,tp,g)
	return c:IsCode(31280146) and not c:IsForbidden() and c:CheckUniqueOnField(tp) and Duel.GetSZoneCount(tp,g)>0
end
function s.fselect(g,tp)
	return Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,tp,g)
end
function s.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_ONFIELD,0,nil)
	if chk==0 then return g:CheckSubGroup(s.fselect,1,2,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sg=g:SelectSubGroup(tp,s.fselect,false,1,2,e,tp)
    Duel.HintSelection(sg)
	local ct=Duel.SendtoDeck(sg,nil,2,REASON_COST)
    e:SetLabel(ct)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end	
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<ct then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,ct,ct,nil,tp,nil)
        for ec in aux.Next(g) do 		
			if not ec or not Duel.Equip(tp,ec,c) then return end
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(s.eqlimit)
			e1:SetLabelObject(c)
			ec:RegisterEffect(e1)
        end     
    end    
end
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
function s.efcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--不会被魔法卡破坏    
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)		
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.efilter)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1,true)
    c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,5))
end
function s.efilter(e,re)
	return re:GetOwner():IsType(TYPE_SPELL)
end
function s.tgfilter(c)
	return c:IsFaceup() and c:IsCode(31280146) and c:IsAbleToGrave()
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and Duel.IsChainDisablable(ev) and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_ONFIELD,0,1,nil) and Duel.GetFlagEffect(tp,id)==0
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local tc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_ONFIELD,0,1,1,nil):GetFirst()
		if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) then
			Duel.Hint(HINT_CARD,0,id)
			if Duel.NegateEffect(ev) and tc:GetOriginalCode()==31280148 and re:GetHandler():IsRelateToEffect(re) 
            	and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
                Duel.BreakEffect()
                Duel.Destroy(re:GetHandler(),REASON_EFFECT)
            end
			e:GetHandler():RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,4))
            Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
	end
end