--玛莉龙忒之花
local this,id,ofs=GetID()
function this.initial_effect(c)
	local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCondition(this.con)
    e1:SetTarget(this.tg)
    e1:SetOperation(this.op)
    c:RegisterEffect(e1)
end
function this.filter(c,e,tp)
    return (c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetMZoneCount(tp)>0 or c:IsAbleToDeck())
    and c:IsRace(RACE_DRAGON) and bit.band(c:GetType(),TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_PENDULUM)~=0
end
function this.con(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(nil,tp,LOCATION_PZONE,0,1,nil)
end
function this.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and this.filter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(this.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    Duel.SelectTarget(tp,this.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
end
function this.op(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if not tc:IsRelateToEffect(e) or not (tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetMZoneCount(tp)>0 or tc:IsAbleToDeck()) then return end
    local v=0
    if not (tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetMZoneCount(tp)>0) then v=1
    elseif not tc:IsAbleToDeck() then v=0
    else v=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1)) end
    if v==0 then
        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		local fid=c:GetFieldID()
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(this.rmcon)
		e1:SetOperation(this.rmop)
		Duel.RegisterEffect(e1,tp)
    else if Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
        local g=Duel.GetMatchingGroup(this.setfilter,tp,LOCATION_DECK,0,nil)
        if g:GetCount()>0 then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
			local sg=g:Select(tp,1,1,nil)
			Duel.SSet(tp,sg)
		end
    end
    end
end
function this.rmcon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject():GetFlagEffectLabel(id)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
function this.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)
end
function this.setfilter(c)
	return c:IsSetCard(0x722) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
