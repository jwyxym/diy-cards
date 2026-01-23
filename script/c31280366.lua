--破壞的歌声
local s,id,o=GetID()
function s.initial_effect(c)
	--发动
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(s.discon)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and bit.band(Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION),LOCATION_ONFIELD+LOCATION_HAND)~=0
end
function s.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3ca1) and c:GetOriginalType()&TYPE_MONSTER~=0
end    
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ct=1
	if not re:GetHandler():IsRelateToEffect(re) then ct=2 end
	if chkc==0 then return chkc:IsOnField() and chkc:IsControler(tp) and s.desfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,0,ct,nil) end	
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,0,ct,3,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK) and c:IsSetCard(0x3ca1)
end    
function s.dfilter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk) and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local ct=g:GetCount()
    local rc=re:GetHandler()
    local res=0
    if ct>=1 then
    	if rc:IsRelateToEffect(re) then
			res=Duel.Destroy(eg,REASON_EFFECT)
		end
    end    
    if ct>=2 then    	
    	if res~=0 then Duel.BreakEffect() end
    	local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
		e1:SetTarget(s.negtg)
		e1:SetLabelObject(rc)
		e1:SetReset(RESET_CHAIN)
		Duel.RegisterEffect(e1,tp)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_CHAIN_SOLVING)
		e2:SetCondition(s.negcon)
		e2:SetOperation(s.negop)
		e2:SetLabelObject(rc)
		e2:SetReset(RESET_CHAIN)
		Duel.RegisterEffect(e2,tp)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
		e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
		e3:SetTarget(s.negtg)
		e3:SetLabelObject(rc)
		e3:SetReset(RESET_CHAIN)
		Duel.RegisterEffect(e3,tp)
        res=1
    end    
    if ct==3 then
    	if res~=0 then Duel.BreakEffect() end
    	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
        local cg=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
        local dc=cg:GetFirst()
        if dc then
        	Duel.HintSelection(cg)
       		local atk=dc:GetAttack()
        	local dg=Duel.GetMatchingGroup(s.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,atk)
        	res=Duel.Destroy(dg,REASON_EFFECT)
        end    
    end
    local sg=g:Filter(Card.IsRelateToEffect,nil,e)
    if res~=0 and sg:GetCount()>0 then
    	Duel.BreakEffect()
        Duel.Destroy(sg,REASON_EFFECT)
    end
end
function s.negtg(e,c)
	local tc=e:GetLabelObject()
	return c:IsOriginalCodeRule(tc:GetOriginalCodeRule())
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return re:GetHandler():IsOriginalCodeRule(tc:GetOriginalCodeRule())
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end