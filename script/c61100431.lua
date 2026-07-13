--本色史莱姆-英雄的颜色
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	s.AddXyzProcedure(c,s.matfilter,3,5,nil,nil,99)
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,4))
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e0:SetCondition(s.xyzcon)
	e0:SetOperation(s.xyzop)
	e0:SetValue(SUMMON_TYPE_XYZ)
	c:RegisterEffect(e0)
	local e0a=Effect.CreateEffect(c)
	e0a:SetType(EFFECT_TYPE_FIELD)
	e0a:SetCode(EFFECT_XYZ_LEVEL)
	e0a:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e0a:SetRange(LOCATION_EXTRA)
	e0a:SetTargetRange(LOCATION_SZONE+LOCATION_MZONE,0)
	e0a:SetTarget(s.lvtg)
	e0a:SetValue(s.lvval)
	c:RegisterEffect(e0a)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e1_2=e1:Clone()
	e1_2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e1_2)
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_SINGLE)
	e1a:SetCode(EFFECT_CHANGE_RANK)
	e1a:SetValue(function(e,c)
		return c:GetOverlayCount()
	end)
	c:RegisterEffect(e1a)
	local e1b=Effect.CreateEffect(c)
	e1b:SetType(EFFECT_TYPE_SINGLE)
	e1b:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1b:SetValue(function(e,c)
		return c:GetRank()*800
	end)
	c:RegisterEffect(e1b)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.discon)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetCountLimit(1,id+10000)
	e3:SetCost(s.cost3)
	e3:SetTarget(s.tg3)
	e3:SetOperation(s.op3)
	c:RegisterEffect(e3)
end
function s.lvtg(e,c)
	return (c:IsLocation(LOCATION_MZONE) and c:IsType(TYPE_XYZ) and c:IsRace(RACE_AQUA) and c:IsRank(3)) or (c:IsXyzType(TYPE_MONSTER) and c:IsType(TYPE_EQUIP) and c:IsLocation(LOCATION_SZONE))
end
function s.lvval(e,c,rc)
	local lv=c:GetLevel()
	if rc==e:GetHandler() then return 3
	else return lv end
end
function s.cost3(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	local g=Duel.GetOverlayGroup(tp,1,0):Select(tp,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
	e:SetLabelObject(g:GetFirst())
end

function s.tg3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(Card.IsCanBeXyzMaterial,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e:GetHandler())
	end
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectMatchingCard(tp,Card.IsCanBeXyzMaterial,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,c)
	if #g>0 then
		Duel.Overlay(c,g)
	end
	local tc=e:GetLabelObject()
	if tc and tc:IsType(TYPE_MONSTER) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(tc:GetCode())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		c:CopyEffect(tc:GetCode(),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
	end
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	local c=e:GetHandler()
	local rc=re:GetHandler()
	local og=c:GetOverlayGroup()
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER)
		and og:IsExists(Card.IsCode,1,nil,rc:GetCode())
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end
function s.xyzcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil,c)
end
function s.xyzfilter(c,xyzc)
	return c:IsCode(61100430) and c:IsFaceup() and c:IsCanBeXyzMaterial(xyzc)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil,c)
	local tc=g:GetFirst()
	if tc then
		local og=tc:GetOverlayGroup()
		if #og>0 then Duel.Overlay(c,og) end
		c:SetMaterial(g)
		Duel.Overlay(c,tc)
		local ng=c:GetOverlayGroup():Select(tp,1,1,nil)
		if #ng>0 then
		Duel.SendtoDeck(ng,nil,SEQ_DECKSHUFFLE,REASON_RULE)
		end
	end
end
function s.matfilter(c)
	return (c:IsLocation(LOCATION_MZONE) and c:IsRace(RACE_AQUA)) or (c:IsXyzType(TYPE_MONSTER) and c:IsType(TYPE_EQUIP) and c:IsLocation(LOCATION_SZONE))
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
