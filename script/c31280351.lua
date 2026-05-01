--奏绝破壞·里榭娜
local s,id,o=GetID()
function s.initial_effect(c)
	--连接召唤	
	aux.AddLinkProcedure(c,nil,2,4,s.lcheck)
	c:EnableReviveLimit()
	--卡组检索    
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--效破耐性    
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--选择效果发动    
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
    e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMING_END_PHASE)
	e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(s.efcon)
	e3:SetTarget(s.eftg)
	e3:SetOperation(s.efop)
	c:RegisterEffect(e3) 
    if not s.global_check then
		s.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROY)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end   
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	for tc in aux.Next(eg) do
    	if tc:IsSetCard(0x3ca1) and tc:IsReason(REASON_BATTLE+REASON_EFFECT) then
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
			Duel.RegisterFlagEffect(1-tp,id,RESET_PHASE+PHASE_END,0,1)
        end    
	end
end
function s.lcheck(g,lc)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x3ca1)
end
function s.thfilter(c)
	return c:IsSetCard(0x3ca1) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.efcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)>=2 
end
function s.efffilter(c,lg,ignore_flag)
	return c:IsType(TYPE_PENDULUM) and (ignore_flag or c:GetFlagEffect(id)==0)
end
function s.ntrfilter(c)
	return c:IsControlerCanBeChanged()
end
function s.PConditionFilter(c,e,tp,lscale,rscale,eset)
	local lv=0
	if c.pendulum_level then
		lv=c.pendulum_level
	else
		lv=c:GetLevel()
	end
	local bool=aux.PendulumSummonableBool(c)
	return (c:IsLocation(LOCATION_HAND+LOCATION_GRAVE) or (c:IsFaceup() and c:IsType(TYPE_PENDULUM)))
		and lv>lscale and lv<rscale and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_PENDULUM,tp,bool,bool) and not c:IsForbidden()
		and (aux.PendulumChecklist&(0x1<<tp)==0 or aux.PConditionExtraFilter(c,e,tp,lscale,rscale,eset))
end
function s.PConditionExtraFilter(c,e,tp,lscale,rscale,eset)
	local lv=0
	if c.pendulum_level then
		lv=c.pendulum_level
	else
		lv=c:GetLevel()
	end
	local bool=aux.PendulumSummonableBool(c)
	return lv>lscale and lv<rscale and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_PENDULUM,tp,bool,bool) and not c:IsForbidden()
end
function s.eftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
    local res=nil
    local lpz=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	local rpz=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
    if lpz~=nil and rpz~=nil then
    	local loc=0
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc+LOCATION_HAND end
		if Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM)>0 then loc=loc+LOCATION_EXTRA end
		if loc~=0 then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_EXTRA_PENDULUM_SUMMON)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetTargetRange(1,0)
			e1:SetValue(s.pendvalue)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
			local eset={e1}
			local lscale=lpz:GetLeftScale()
			local rscale=rpz:GetRightScale()
			if lscale>rscale then lscale,rscale=rscale,lscale end
			local g=Duel.GetFieldGroup(tp,loc,0)
            if Duel.IsPlayerAffectedByEffect(tp,31280415) then
            	local pg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)
				g:Merge(pg)
            end    
			res=g:IsExists(s.PConditionFilter,1,nil,e,tp,lscale,rscale,eset)
			e1:Reset()
        end 
    end      
	local b1=res and Duel.GetFlagEffect(tp,31280356)==0 
    local b2=Duel.IsExistingMatchingCard(s.ntrfilter,tp,0,LOCATION_MZONE,1,nil)
    	and Duel.GetFlagEffect(tp,31280357)==0
    if chk==0 then return (b1 or b2) and Duel.GetFlagEffect(tp,id+o*10000)==0 end
    Duel.RegisterFlagEffect(tp,id+o*10000,RESET_CHAIN,0,1)
    local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,2),1},
		{b2,aux.Stringid(id,3),2})
	e:SetLabel(op)
    if op==1 then
    	Duel.RegisterFlagEffect(tp,31280356,RESET_PHASE+PHASE_END,0,1)
    	e:SetCategory(CATEGORY_SPECIAL_SUMMON)               
    elseif op==2 then
    	Duel.RegisterFlagEffect(tp,31280357,RESET_PHASE+PHASE_END,0,1)
        e:SetCategory(CATEGORY_CONTROL+CATEGORY_DISABLE)    
        Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,1-tp,LOCATION_MZONE)            
    end
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.pendvalue(e,c)
	return c:IsSetCard(0x3ca1)
end
function s.dfilter(c,race)
	return c:IsFaceup() and c:IsRace(race) and c:GetOriginalType()&TYPE_PENDULUM~=0
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=e:GetLabel()
	if op==1 then    	
        local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_EXTRA_PENDULUM_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetValue(s.pendvalue)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
		local eset={e1}
		local lpz=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
		local rpz=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
		local lscale=lpz:GetLeftScale()
		local rscale=rpz:GetRightScale()
		if lscale>rscale then lscale,rscale=rscale,lscale end
		local loc=0
		local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
		local ft2=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM)
		local ft=Duel.GetUsableMZoneCount(tp)
		local ect=c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]
		if ect and ect<ft2 then ft2=ect end
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then
			if ft1>0 then ft1=1 end
			if ft2>0 then ft2=1 end
			ft=1
		end
		if ft1>0 then loc=loc|LOCATION_HAND end
		if ft2>0 then loc=loc|LOCATION_EXTRA end
		local tg=Duel.GetMatchingGroup(s.PConditionFilter,tp,loc,0,nil,e,tp,lscale,rscale,eset)
		tg=tg:Filter(aux.PConditionExtraFilterSpecific,nil,e,tp,lscale,rscale,e1)
        if Duel.IsPlayerAffectedByEffect(tp,31280415) then
        	local pg=Duel.GetMatchingGroup(s.PConditionExtraFilter,tp,LOCATION_GRAVE,0,nil,e,tp,lscale,rscale,eset)
			tg:Merge(pg)
        end    
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		aux.GCheckAdditional=aux.PendOperationCheck(ft1,ft2,ft)
		local g=tg:SelectSubGroup(tp,aux.TRUE,false,1,math.min(#tg,ft))
		aux.GCheckAdditional=nil
		if not g then
			e1:Reset()
			return
		end
		local sg=Group.CreateGroup()
		sg:Merge(g)
		Duel.HintSelection(Group.FromCards(lpz))
		Duel.HintSelection(Group.FromCards(rpz))
		Duel.RaiseEvent(sg,EVENT_SPSUMMON_SUCCESS_G_P,e,REASON_EFFECT,tp,tp,0)
		Duel.SpecialSummon(sg,SUMMON_TYPE_PENDULUM,tp,tp,true,true,POS_FACEUP)
		e1:Reset()   
	elseif op==2 then
    	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
		local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,0,LOCATION_MZONE,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			Duel.HintSelection(g)
			if Duel.GetControl(tc,tp)~=0 then
            	local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e2)
                if Duel.IsExistingMatchingCard(s.dfilter,tp,LOCATION_PZONE,0,1,nil,RACE_FAIRY)
					and Duel.IsExistingMatchingCard(s.dfilter,tp,LOCATION_PZONE,0,1,nil,RACE_FIEND) then
                	Duel.BreakEffect()
            		local e3=Effect.CreateEffect(c)
					e3:SetType(EFFECT_TYPE_SINGLE)
					e3:SetCode(EFFECT_ADD_SETCODE)
					e3:SetValue(0x3ca1)
					e3:SetReset(RESET_EVENT+RESETS_STANDARD)
					tc:RegisterEffect(e3)
                end    
            end
		end        
    end
end