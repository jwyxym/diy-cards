--本色史莱姆-祝福的颜色
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	s.AddXyzProcedure(c,s.matfilter,3,3,nil,nil,99)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_XYZ_LEVEL)
	e0:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetTargetRange(LOCATION_SZONE,0)
	e0:SetTarget(s.lvtg)
	e0:SetValue(s.lvval)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.valcon)
	c:RegisterEffect(e1)
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_SINGLE)
	e1a:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1a:SetRange(LOCATION_MZONE)
	e1a:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1a:SetValue(aux.tgoval)
	c:RegisterEffect(e1a)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon2)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMING_MAIN_END,TIMINGS_CHECK_MONSTER)
	e3:SetCountLimit(1,id+10000)
	e3:SetCondition(s.condition)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
function s.lvtg(e,c)
	return c:IsXyzType(TYPE_MONSTER) and c:IsType(TYPE_EQUIP)
end
function s.lvval(e,c,rc)
	local lv=c:GetLevel()
	if rc==e:GetHandler() then return 3
	else return lv end
end
function s.valcon(e,re,r,rp)
	if bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0 then
		return 1
	else
		return 0
	end
end
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

function s.spfilter(c,e,tp)
	return bit.band(c:GetOriginalType(),TYPE_MONSTER)~=0 and c:IsType(TYPE_EQUIP) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_SZONE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_SZONE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_SZONE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

function s.splimit(e,c)
	return not c:IsRace(RACE_AQUA)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase() and not Duel.IsExistingMatchingCard(s.exfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.exfilter(c)
	return c:IsFaceup() and not c:IsRace(RACE_AQUA)
end
function s.filter(c)
	return c:IsRace(RACE_AQUA) and c:IsAbleToDeck()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return e:GetHandler():IsAbleToDeck()
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,99,nil)
	g:AddCard(e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local ag=Group.FromCards(c)
	ag:Merge(tg)
	local bg=c:GetOverlayGroup()
	ag:Merge(bg)
	if Duel.SendtoDeck(ag,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==0 then return end
	local ct=ag:FilterCount(Card.IsLocation,nil,LOCATION_DECK)
	if ct>0 then
		Duel.ConfirmDecktop(tp,tc)
		local g=Duel.GetDecktopGroup(tp,ct):Filter(Card.IsRace,nil,RACE_AQUA)
		local mg=Duel.GetDecktopGroup(tp,ct):Filter(Card.IsRace,nil,RACE_AQUA)
	local exg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,mg,#mg)
	local b1=g:IsExists(function(c) return c:IsRace(RACE_AQUA) and c:IsAbleToHand() end,1,nil)
	local b2=mg:CheckSubGroup(s.fgoal,2,#mg,exg)
		local op=aux.SelectFromOptions(tp,{b1,aux.Stringid(id,3)},{b2,aux.Stringid(id,4)},{true,aux.Stringid(id,5)})
		if op==1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local tc=g:Select(tp,1,1,nil)
				if tc then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
		elseif op==2 then
	local exg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,mg,#mg)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg1=mg:SelectSubGroup(tp,s.fgoal,false,2,#mg,exg)
	local ng=sg1:Filter(s.filter2,nil,e,tp)
	Duel.AdjustAll()
	local xyzg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil,ng,#ng)
	if ct>=2 and xyzg:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
		Duel.XyzSummon(tp,xyz,ng)
			end
		end
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.filter2(c,e,tp)
	return c:IsRace(RACE_AQUA)
end

function s.spfilter(c,mg,ct)
	return c:IsXyzSummonable(mg,ct,ct)
end

function s.xyzfilter(c,mg,ct)
	return c:IsXyzSummonable(mg,2,ct)
end

function s.fgoal(sg,exg)
	return aux.dncheck(sg) and exg:IsExists(Card.IsXyzSummonable,1,nil,sg,#sg,#sg)
end
function s.matfilter(c)
	return (c:IsLevel(3) and c:IsLocation(LOCATION_MZONE) and c:IsRace(RACE_AQUA)) or (c:IsXyzType(TYPE_MONSTER) and c:IsType(TYPE_EQUIP) and c:IsLocation(LOCATION_SZONE))
end
function s.AddXyzProcedure(c,f,lv,ct,alterf,alterdesc,maxct,alterop)
	if not maxct then maxct=ct end
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(1165)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.XyzCondition(f,lv,ct,maxct,alterf,alterdesc,alterop))
	e1:SetTarget(s.XyzTarget(f,lv,ct,maxct,alterf,alterdesc,alterop))
	e1:SetOperation(s.XyzOperation(f,lv,ct,maxct,alterf,alterdesc,alterop))
	e1:SetValue(SUMMON_TYPE_XYZ)
	c:RegisterEffect(e1)
end
function s.XyzCondition(f,lv,minct,maxct,alterf,alterdesc,alterop)
	return  function(e,c,og,min,max)
				if c==nil then return true end
				if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
				local tp=c:GetControler()
				local mg=nil
				if og then
					mg=og
				else
					mg=Duel.GetFieldGroup(tp,LOCATION_MZONE+LOCATION_SZONE,0)
				end
				if alterf and (not min or min<=1) then
					if mg:IsExists(Auxiliary.XyzAlterFilter,1,nil,alterf,c,e,tp,alterop) then
						return true
					end
				end
				local minc=minct
				local maxc=maxct
				if min then
					if min>minc then minc=min end
					if max<maxc then maxc=max end
				end
				if minct>=3 and mg:IsExists(Auxiliary.Xyz2XMaterialEffectFilter,1,nil,c,lv,f,tp) then
					return Auxiliary.CheckXyz2XMaterial(c,f,lv,minc,maxc,mg)
				else
					if minc>maxc then return false end
					return Duel.CheckXyzMaterial(c,f,lv,minc,maxc,og)
				end
			end
end
function s.XyzTarget(f,lv,minct,maxct,alterf,alterdesc,alterop)
	return  function(e,tp,eg,ep,ev,re,r,rp,chk,c,og,min,max)
				if og and not min then
					return true
				end
				local minc=minct
				local maxc=maxct
				if min then
					if min>minc then minc=min end
					if max<maxc then maxc=max end
				end
				local b1=true
				local b2=false
				local altg=nil
				local mg=nil
				if og then
					mg=og
				else
					mg=Duel.GetFieldGroup(tp,LOCATION_MZONE+LOCATION_SZONE,0)
				end
				if alterf and (not min or min<=1) then
					altg=mg:Filter(Auxiliary.XyzAlterFilter,nil,alterf,c,e,tp,alterop)
					if minct>=3 and mg:IsExists(Auxiliary.Xyz2XMaterialEffectFilter,1,nil,c,lv,f,tp) then
						b1=Auxiliary.CheckXyz2XMaterial(c,f,lv,minc,maxc,mg)
					else
						b1=Duel.CheckXyzMaterial(c,f,lv,minc,maxc,og)
					end
					b2=#altg>0
				end
				local g=nil
				if b2 and (not b1 or Duel.SelectYesNo(tp,alterdesc)) then
					e:SetLabel(1)
					local cancel=Duel.IsSummonCancelable()
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
					local tc=altg:SelectUnselect(nil,tp,false,cancel,1,1)
					if tc then
						g=Group.FromCards(tc)
						if alterop then alterop(e,tp,1,tc) end
					end
				else
					e:SetLabel(0)
					if minct>=3 and mg:IsExists(Auxiliary.Xyz2XMaterialEffectFilter,1,nil,c,lv,f,tp) then
						mg=mg:Filter(Auxiliary.Xyz2XMaterialFilter,nil,c,lv,f)
						local cancel=Duel.IsSummonCancelable()
						local sg=Duel.GetMustMaterial(tp,EFFECT_MUST_BE_XMATERIAL)
						Duel.SetSelectedCard(sg)
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
						Auxiliary.GCheckAdditional=Auxiliary.TuneMagicianCheckAdditionalX(EFFECT_TUNE_MAGICIAN_X)
						g=mg:SelectSubGroup(tp,Auxiliary.Xyz2XMaterialGoal,cancel,2,maxc,tp,c,minc)
						Auxiliary.GCheckAdditional=nil
					else
						g=Duel.SelectXyzMaterial(tp,c,f,lv,minc,maxc,og)
					end
				end
				if g then
					g:KeepAlive()
					e:SetLabelObject(g)
					return true
				else return false end
			end
end
function s.XyzOperation(f,lv,minct,maxct,alterf,alterdesc,alterop)
	return  function(e,tp,eg,ep,ev,re,r,rp,c,og,min,max)
				if og and not min then
					Auxiliary.Xyz2XMaterialOperation(tp,og,c,minct,maxct)
					local sg=Group.CreateGroup()
					local tc=og:GetFirst()
					while tc do
						local sg1=tc:GetOverlayGroup()
						sg:Merge(sg1)
						tc=og:GetNext()
					end
					Duel.SendtoGrave(sg,REASON_RULE)
					c:SetMaterial(og)
					Duel.Overlay(c,og)
				else
					local mg=e:GetLabelObject()
					if e:GetLabel()==1 then
						local mg2=mg:GetFirst():GetOverlayGroup()
						if mg2:GetCount()~=0 then
							Duel.Overlay(c,mg2)
						end
					else
						Auxiliary.Xyz2XMaterialOperation(tp,mg,c,minct,maxct)
						local sg=Group.CreateGroup()
						local tc=mg:GetFirst()
						while tc do
							local sg1=tc:GetOverlayGroup()
							sg:Merge(sg1)
							tc=mg:GetNext()
						end
						Duel.SendtoGrave(sg,REASON_RULE)
					end
					c:SetMaterial(mg)
					Duel.Overlay(c,mg)
					mg:DeleteGroup()
				end
			end
end
