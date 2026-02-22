--救世游戏-念力协调者
local s,id,o=GetID()
function s.initial_effect(c)
	--超量召唤
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0xdf99),3,2)
	c:EnableReviveLimit()
	--补充超量素材    
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.mttg)
	e1:SetOperation(s.mtop)
	c:RegisterEffect(e1)
	--改变卡名    
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_ONFIELD)
	e2:SetCode(EFFECT_CHANGE_CODE)
    e2:SetCondition(s.cccon)
    e2:SetTarget(s.cctg)
	e2:SetValue(77571455)
	c:RegisterEffect(e2)
	--选择效果发动
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
    e3:SetHintTiming(0,TIMING_MAIN_END)
	e3:SetCountLimit(1,id+o)
    e3:SetCost(s.chcost)
	e3:SetTarget(s.chtg)
	e3:SetOperation(s.chop)
	c:RegisterEffect(e3)        
end    
function s.mtfilter(c,e)
	return c:IsCanOverlay() and not (e and c:IsImmuneToEffect(e))
end
function s.mttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		and Duel.IsExistingMatchingCard(s.mtfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,0,0)
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.mtfilter),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e)
	if g:GetCount()>0 then
		Duel.Overlay(c,g)
	end
end
function s.cccon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayCount()>0
end
function s.cfilter(c,zone)
	local seq=aux.MZoneSequence(c:GetSequence())
	return c:IsFaceup() and c:IsSetCard(0xdf99) and seq==4-zone
end
function s.cctg(e,c)
	local seq=aux.MZoneSequence(c:GetSequence())
	return c:GetOriginalCode()~=77571455 and Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil,seq)
end
function s.chcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsSetCard(0xdf99)
end
function s.setfilter(c,tp)
	return c:IsType(TYPE_CONTINUOUS) and c:IsSetCard(0xdf99) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.mvfilter(c)
	local seq=c:GetSequence()
	local tp=c:GetControler()
	if seq>4 then return false end
	return (seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1))
		or (seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1))
end
function s.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
    local b2=Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_GRAVE,0,1,nil,tp)
	if chk==0 then return (b1 or b2) and Duel.IsExistingMatchingCard(s.mvfilter,tp,LOCATION_MZONE,0,1,nil) end
    local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,2),1},
		{b2,aux.Stringid(id,3),2})
	e:SetLabel(op)
    if op==1 then
    	e:SetCategory(CATEGORY_SPECIAL_SUMMON)
    	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
    elseif op==2 then
    	e:SetCategory(CATEGORY_LEAVE_GRAVE)
        Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,0,0)
    end
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	local res=0
	local op=e:GetLabel()
	if op==1 then
    	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			res=Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif op==2 then
    	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
		if tc then 
        	res=Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) 
        end
    end
    if res~=0 then
    	Duel.BreakEffect()
    	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,4))
		local sg=Duel.SelectMatchingCard(tp,s.mvfilter,tp,LOCATION_MZONE,0,1,1,nil)
		if sg:GetCount()>0 then
			local sc=sg:GetFirst()
			local seq=sc:GetSequence()
			if seq>4 then return end
			local flag=0
			if seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1) then flag=flag|(1<<(seq-1)) end
			if seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1) then flag=flag|(1<<(seq+1)) end
			if flag==0 then return end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
			local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,~flag)
			local nseq=math.log(s,2)
			Duel.HintSelection(sg)
			Duel.MoveSequence(sc,nseq)
		end
    end
end