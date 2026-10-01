--异侵啮鸣-雷姬
local s,id,o=GetID()
function s.initial_effect(c)
	--超量召唤
	aux.AddXyzProcedure(c,nil,9,2,nil,nil,99)
	c:EnableReviveLimit()
	--适用效果    
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
    e1:SetCost(s.efcost)
	e1:SetTarget(s.eftg)
	e1:SetOperation(s.efop)
	c:RegisterEffect(e1)
	--破坏 
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)  
end
function s.efcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
    local oc=c:GetOverlayCount()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	local ct=c:RemoveOverlayCard(tp,1,oc,REASON_COST)
    e:SetLabel(ct)
end
function s.eftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetLabel()
	if chk==0 then return true end
    if ct>=1 then
    	e:SetCategory(CATEGORY_ATKCHANGE)
    elseif ct>=2 then    
    	e:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
        Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
    end
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local ct=e:GetLabel()
    local res=0
    if ct>=1 then
    	if c:IsRelateToEffect(e) and c:IsFaceup() then
        	local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(600)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
            res=1
        end
    end
    if ct>=2 then
    	if res~=0 then Duel.BreakEffect() end
    	if Duel.IsPlayerCanSpecialSummonMonster(tp,16190686,0,TYPES_TOKEN_MONSTER,2800,1400,9,RACE_DRAGON,ATTRIBUTE_DARK,POS_FACEUP) 
        	and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
        	local token=Duel.CreateToken(tp,16190686)
			res=Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
        end
    end
    if ct>=3 then
    	if res~=0 then Duel.BreakEffect() end
    	if Duel.GetFlagEffect(tp,id)==0 then
        	Duel.RegisterFlagEffect(tp,id,0,0,0)
            Duel.Hint(HINT_CARD,0,id)
            local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_DELAY)
			e1:SetCode(EVENT_TO_GRAVE)
			e1:SetCondition(s.spcon)
			e1:SetOperation(s.spop)			
			Duel.RegisterEffect(e1,tp)
        end
    end
end
function s.confilter(c,tp)
	return c:GetReasonPlayer()==1-tp and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
    	and c:GetPreviousCodeOnField()==id
end
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsCode(id) 
    	and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.confilter,1,nil,tp) and Duel.GetFlagEffect(tp,id+o)==0 
    	and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or Duel.GetFlagEffect(tp,id+o)>0 or not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return end
    Duel.Hint(HINT_CARD,0,id)
    Duel.RegisterFlagEffect(tp,id+o,0,0,0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(16190686)
end    
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	local ct=1
	if Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_ONFIELD,0,nil)>0 then ct=2 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,ct,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end    
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 and Duel.Destroy(tg,REASON_EFFECT)~=0 then
    	for tc in aux.Next(tg) do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
			e1:SetTarget(s.distg)
			e1:SetLabelObject(tc)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e2:SetCode(EVENT_CHAIN_SOLVING)
			e2:SetCondition(s.discon)
			e2:SetOperation(s.disop)
			e2:SetLabelObject(tc)
			e2:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e2,tp)
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_FIELD)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
			e3:SetTarget(s.distg)
			e3:SetLabelObject(tc)
			e3:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e3,tp)
		end
	end
end
function s.distg(e,c)
	local tc=e:GetLabelObject()
	return c:IsOriginalCodeRule(tc:GetOriginalCodeRule())
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return re:GetHandler():IsOriginalCodeRule(tc:GetOriginalCodeRule())
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end