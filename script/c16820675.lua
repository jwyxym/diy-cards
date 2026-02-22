--救世游戏-死亡代言人
local s,id,o=GetID()
function s.initial_effect(c)
	--连接召唤
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,nil,2,3,s.lcheck)
	--无效    
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.discon)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	--得到控制权    
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.ntrcon)
	e2:SetTarget(s.ntrtg)
	e2:SetOperation(s.ntrop)
	c:RegisterEffect(e2)        
end
function s.lcheck(g,lc)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0xdf99)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if ev<=1 then return false end
	return not c:IsStatus(STATUS_BATTLE_DESTROYED)
		and (Duel.IsChainDisablable(ev) or Duel.IsChainDisablable(ev-1))
end
function s.mvfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xdf99)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsChainDisablable(ev)
	local b2=Duel.IsChainDisablable(ev-1)
    local zone=bit.band(e:GetHandler():GetLinkedZone(),0x1f)
	if chk==0 then return (b1 or b2) and Duel.IsExistingMatchingCard(s.mvfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
    	and Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0,zone)>0 end
	local te=Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT)
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,2),1},
		{b2,aux.Stringid(id,3),2})
	e:SetLabel(op)
	if op==1 then
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
		if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
			Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
		end
	elseif op==2 then
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,te:GetHandler(),1,0,0)
		if te:GetHandler():IsDestructable() and te:GetHandler():IsRelateToEffect(te) then
			Duel.SetOperationInfo(0,CATEGORY_DESTROY,te:GetHandler(),1,0,0)
		end
	end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local res=0
	local op=e:GetLabel()
	if op==1 then
		if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToChain(ev) then
			res=Duel.Destroy(eg,REASON_EFFECT)
		end
	elseif op==2 then
		local te=Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT)
		if Duel.NegateEffect(ev-1) and te:GetHandler():IsRelateToChain(ev-1) then
			res=Duel.Destroy(te:GetHandler(),REASON_EFFECT)
		end
	end
    if res~=0 then
    	Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,4))
		local sg=Duel.SelectMatchingCard(tp,s.mvfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
        if sg:GetCount()>0 then
        	local tc=sg:GetFirst()
        	local zone=bit.band(e:GetHandler():GetLinkedZone(),0x1f)
			if not tc or tc:IsControler(1-tp) or Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0,zone)<=0 then return end
        	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
			local flag=bit.bxor(zone,0xff)
			local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,flag)
			local nseq=math.log(s,2)
            Duel.HintSelection(sg)
			Duel.MoveSequence(tc,nseq)
        end
    end
end
function s.ntrcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp) 
    	and c:GetReasonPlayer()==1-tp
end
function s.ntrfilter(c)
	return c:IsControlerCanBeChanged()
end
function s.ntrtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.ntrfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,1-tp,LOCATION_MZONE)
end
function s.ntrop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectMatchingCard(tp,s.ntrfilter,tp,0,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.HintSelection(g)
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end