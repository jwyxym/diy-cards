--无垠之花·蔓生
local this,id,ofs=GetID()
function this.initial_effect(c)
	local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetTarget(this.tg)
    e1:SetOperation(this.op)
    c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(this.tdtg)
	e2:SetOperation(this.tdop)
	c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetTarget(this.tdtg2)
    c:RegisterEffect(e3)
end
function this.GetLevel(c)
    if bit.band(c:GetOriginalType(),TYPE_XYZ)~=0 then return c:GetOriginalRank()
    elseif bit.band(c:GetOriginalType(),TYPE_LINK)~=0 then return c:GetLink()
    else return c:GetOriginalLevel() end
end
function this.filter(c,e,tp)
    return c:IsLocation(LOCATION_GRAVE) and c:IsControler(tp) and c:IsSetCard(0x3410) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
    or c:GetOriginalType()&TYPE_MONSTER>0 and c:GetType()&TYPE_CONTINUOUS+TYPE_TRAP==TYPE_CONTINUOUS+TYPE_TRAP
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function this.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return this.filter(chkc,e,tp) end
    if chk==0 then return Duel.IsExistingTarget(this.filter,tp,LOCATION_SZONE+LOCATION_GRAVE,LOCATION_SZONE,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local tc=Duel.SelectTarget(tp,this.filter,tp,LOCATION_SZONE+LOCATION_GRAVE,LOCATION_SZONE,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,0,0)
end
function this.op(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
end
function this.tdfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0x3410) and not c:IsCode(id) and c:IsFaceupEx()
		and c:IsAbleToDeck()
end
function this.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and this.tdfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(this.tdfilter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,this.tdfilter,tp,LOCATION_REMOVED,0,1,3,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end
function this.tdtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and this.tdfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(this.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,this.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function this.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetsRelateToChain()
	if g:GetCount()>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
