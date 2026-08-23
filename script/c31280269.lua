--双极的生命之烈焰·琉璃
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,31280264,31280265)
	--融合召唤
	aux.AddFusionProcFunFun(c,s.mfilter1,s.mfilter2,2,true)
	c:EnableReviveLimit()
	--特召限制
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.fuslimit)
	c:RegisterEffect(e0)
 	--视为水·炎属性
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_ADD_ATTRIBUTE)
	e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e1:SetValue(ATTRIBUTE_WATER+ATTRIBUTE_FIRE)
	c:RegisterEffect(e1)
	--直接攻击    
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e2)    
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
    e3:SetCondition(s.atkcon)
	e3:SetValue(s.atkval)	
	c:RegisterEffect(e3)
	--破坏和抽卡    
    local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    e4:SetCountLimit(1,id)
    e4:SetCondition(s.descon)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)     
end
function s.mfilter1(c)
	return c:IsFusionAttribute(ATTRIBUTE_DARK) and c:IsFusionType(TYPE_FUSION)
end
function s.mfilter2(c)
	return c:IsFusionAttribute(ATTRIBUTE_FIRE+ATTRIBUTE_WATER) and c:IsRace(RACE_ILLUSION)
end
function s.atkcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.GetAttacker()==e:GetHandler() and Duel.GetAttackTarget()==nil and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)~=0
		and e:GetHandler():GetEffectCount(EFFECT_DIRECT_ATTACK)==1
end
function s.atkval(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end    
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local g=c:GetMaterial()
    local b1,b2=nil,nil
    local cg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local ct=aux.GetAttributeCount(cg)
    local dt=ct-1
    if g:IsExists(Card.IsOriginalCodeRule,1,nil,31280265) then
		b1=Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
    end    
    if g:IsExists(Card.IsOriginalCodeRule,1,nil,31280264) then
    	b2=Duel.IsPlayerCanDraw(tp,ct) and ct>0
    end    
	if chk==0 then return (b1 or b2) end
    if b1 and b2 then
    	e:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW+CATEGORY_TODECK)
        local dg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,dg:GetCount(),0,0)
        Duel.SetTargetPlayer(tp)
		Duel.SetTargetParam(ct)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,ct,tp,LOCATION_HAND)    
	elseif b1 then	
		e:SetCategory(CATEGORY_DESTROY)
        local dg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,dg:GetCount(),0,0)
	elseif b2 then
    	e:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
        Duel.SetTargetPlayer(tp)
		Duel.SetTargetParam(ct)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,dt,tp,LOCATION_HAND)
	end    
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetMaterial()
	if #g==0 then return end
	if g:IsExists(Card.IsOriginalCodeRule,1,nil,31280265) then
    	local dg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
    	Duel.Destroy(dg,REASON_EFFECT)
	end
    if g:IsExists(Card.IsOriginalCodeRule,1,nil,31280264) then
    	local cg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
		local ct=aux.GetAttributeCount(cg)
        local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
        local dc=Duel.Draw(p,ct,REASON_EFFECT)
        if dc>=2 then        	
        	Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)
            local dt=dc-1
			local rg=Duel.GetFieldGroup(p,LOCATION_HAND,0):Select(p,dt,dt,nil)
			Duel.ShuffleHand(p)
			aux.PlaceCardsOnDeckBottom(p,rg)
		end    
	end
end