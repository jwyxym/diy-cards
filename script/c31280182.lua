--烈霸工匠·蕾吉
local s,id,o=GetID()
function s.initial_effect(c)
	--连接召唤	
	aux.AddLinkProcedure(c,nil,2,3,s.lcheck)
    c:EnableReviveLimit()
	--移动    
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.mvcon)
	e1:SetTarget(s.mvtg)
	e1:SetOperation(s.mvop)
	c:RegisterEffect(e1)
	--抽卡    
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_CHAINING)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.drcon)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
	--破坏    
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o*10000)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCost(s.descost)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
function s.lcheck(g,lc)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0xcca1)
end
function s.mvcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_LINK) and c:GetSequence()>4
end
function s.mvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)>0 end
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.mvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) or not c:IsControler(tp) or Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	local fd=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
	Duel.Hint(HINT_ZONE,tp,fd)
	local seq=math.log(fd,2)
	local pseq=c:GetSequence()
	Duel.MoveSequence(c,seq)
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rc:GetOriginalType()&(TYPE_PENDULUM|TYPE_MONSTER)==TYPE_PENDULUM|TYPE_MONSTER and not re:IsHasType(EFFECT_TYPE_ACTIVATE) 
    	and re:GetActivateLocation()&LOCATION_ONFIELD~=0 
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and c:GetAttack()>c:GetBaseAttack() end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
function s.costfilter(c)
	return c:IsFaceup() and c:IsAbleToGraveAsCost() and ((c:IsType(TYPE_PENDULUM) and c:IsType(TYPE_MONSTER)) or c:IsSetCard(0xcca1)) 
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_ONFIELD+LOCATION_EXTRA,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_ONFIELD+LOCATION_EXTRA,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) 
    	and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
    	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
        if g:GetCount()<=0 then return end
    	for sc in aux.Next(g) do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(400)
			sc:RegisterEffect(e1)            
		end            
	end
end