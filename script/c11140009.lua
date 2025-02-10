--噬梦的浊流·刃
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
    aux.AddXyzProcedure(c,s.ofilter,10,3,s.ovfilter,aux.Stringid(id,0),3,s.xyzop)
	aux.EnablePendulumAttribute(c,false)
    --炸卡
    local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCondition(s.con)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e2)
    --o
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetRange(LOCATION_PZONE)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_SUMMON_SUCCESS)
    e3:SetCondition(s.ovcon)
    e3:SetTarget(s.ovtg)
    e3:SetOperation(s.ovop)
    c:RegisterEffect(e3)
    local e4=e1:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
    --ATK
    local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_XMATERIAL)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EFFECT_UPDATE_ATTACK)
	e6:SetCondition(s.atkcon)
	e6:SetValue(500)
	c:RegisterEffect(e6)
    --extra att
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_XMATERIAL)
    e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetCode(EFFECT_EXTRA_ATTACK)
    e7:SetRange(LOCATION_MZONE)
    e7:SetCondition(s.atkcon)
	e7:SetValue(1)
	c:RegisterEffect(e7)
    --pendulum
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e8:SetCode(EVENT_DESTROYED)
	e8:SetProperty(EFFECT_FLAG_DELAY)
	e8:SetCondition(s.pencon)
	e8:SetTarget(s.pentg)
	e8:SetOperation(s.penop)
	c:RegisterEffect(e8)
    --
    Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
    --召唤词
    local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e9:SetCode(EVENT_SPSUMMON_SUCCESS)
    e9:SetCountLimit(1)
	e9:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e9:SetOperation(s.thop)
	c:RegisterEffect(e9)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Debug.Message("能在这浪潮中行动的，唯有我一人。")
end
function s.chainfilter(re,tp,cid)
	return not (re:GetHandler():IsRace(RACE_SEASERPENT) and re:GetHandler():IsType(TYPE_XYZ))
end
--over
function s.ofilter(c)
    return c:IsFaceup() and c:IsRace(RACE_SEASERPENT)
end
function s.ovfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SEASERPENT) and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.xyzop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0
		and (Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)>0
			or Duel.GetCustomActivityCount(id,1-tp,ACTIVITY_CHAIN)>0) end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
--pendulum
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
--des
function s.con(e)
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SEASERPENT)
end
function s.filter(e,c)
	return c:IsFaceup() and c:IsRace(RACE_SEASERPENT)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,e:GetHandler())
		and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g1=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g2=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,2,2,nil)
	g1:Merge(g2)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,g1:GetCount(),0,0)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	Duel.Destroy(sg,REASON_EFFECT)
    if c:IsRelateToEffect(e) then
        Duel.BreakEffect()
        Duel.Destroy(c,REASON_EFFECT)
        Debug.Message("……四分五裂吧。")
    end
end
--ov
function s.cfilter1(c,sp)
	return c:IsSummonPlayer(sp)
end
function s.ovcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter1,1,nil,1-tp)
end
function s.ovfilter1(c)
    return c:IsFaceup() and c:IsRace(RACE_SEASERPENT) and c:IsType(TYPE_XYZ)
end
function s.ovtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and this.ovfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.ovfilter1,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    Duel.SelectTarget(tp,s.ovfilter1,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.ovop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
    if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
        Duel.Overlay(tc,c)
    end
end
--atk
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsRace(RACE_SEASERPENT) and c:IsType(TYPE_XYZ)
end